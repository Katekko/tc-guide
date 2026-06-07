#!/usr/bin/env python3
"""Schema-less FlatBuffer explorer for the TC Cocos config .ft files.

Walks vtables to enumerate fields and heuristically types each one
(int / float / string / vector / sub-table) so we can reverse the layout
of HeroCfg & friends without the generated schema.
"""
import struct, sys, json

def u8(b, o):  return b[o]
def u16(b, o): return struct.unpack_from('<H', b, o)[0]
def i16(b, o): return struct.unpack_from('<h', b, o)[0]
def u32(b, o): return struct.unpack_from('<I', b, o)[0]
def i32(b, o): return struct.unpack_from('<i', b, o)[0]
def f32(b, o): return struct.unpack_from('<f', b, o)[0]

class Table:
    def __init__(self, buf, pos):
        self.buf = buf
        self.pos = pos
        soffset = i32(buf, pos)
        self.vt = pos - soffset
        self.vt_size = u16(buf, self.vt)
        self.tbl_size = u16(buf, self.vt + 2)
        self.nfields = (self.vt_size - 4) // 2

    def rel(self, i):
        vo = self.vt + 4 + i * 2
        if vo + 2 > self.vt + self.vt_size:
            return 0
        return u16(self.buf, vo)

    def fpos(self, i):
        r = self.rel(i)
        return self.pos + r if r else None

def deref_uoffset(buf, pos):
    """A uoffset field stores a u32 pointing forward from its own location."""
    return pos + u32(buf, pos)

def read_string(buf, pos):
    p = deref_uoffset(buf, pos)
    ln = u32(buf, p)
    return buf[p + 4: p + 4 + ln].decode('utf-8', 'replace')

def read_vector_meta(buf, pos):
    p = deref_uoffset(buf, pos)
    ln = u32(buf, p)
    return p + 4, ln  # (start of elements, count)

def root(buf):
    return Table(buf, u32(buf, 0))

def looks_ascii(s):
    return all(32 <= ord(c) < 127 or c in '\n\r\t' for c in s) if s else False

def describe_field(buf, t, i, depth=0):
    fp = t.fpos(i)
    if fp is None:
        return None
    # Try to classify. Inline scalars live AT fp; strings/vectors/tables are uoffsets.
    out = {'field': i, 'at': fp}
    # raw 4 bytes
    raw32 = u32(buf, fp)
    out['u32'] = raw32
    out['i32'] = i32(buf, fp)
    fv = f32(buf, fp)
    if abs(fv) > 1e-6 and abs(fv) < 1e9:
        out['f32'] = round(fv, 4)
    # try string
    try:
        target = deref_uoffset(buf, fp)
        if 0 < target < len(buf) - 4:
            ln = u32(buf, target)
            if 0 <= ln < 4000 and target + 4 + ln <= len(buf):
                s = buf[target + 4: target + 4 + ln].decode('utf-8', 'replace')
                if looks_ascii(s) or '一' <= (s[:1] or ' ') <= '鿿':
                    out['str?'] = s[:120]
    except Exception:
        pass
    return out

def dump_table(buf, pos, indent='  '):
    t = Table(buf, pos)
    for i in range(t.nfields):
        fp = t.fpos(i)
        if fp is None:
            continue
        line = f'{indent}f[{i:2}] @{fp}: u32={u32(buf,fp):<10} i32={i32(buf,fp):<11}'
        fv = f32(buf, fp)
        if 1e-4 < abs(fv) < 1e9:
            line += f' f32={round(fv,3):<10}'
        # try string
        try:
            target = deref_uoffset(buf, fp)
            if 0 < target < len(buf) - 4:
                ln = u32(buf, target)
                if 0 <= ln < 4000 and target + 4 + ln <= len(buf):
                    s = buf[target + 4: target + 4 + ln].decode('utf-8', 'replace')
                    printable = sum(1 for c in s if c.isprintable() or c in '\n\r\t')
                    if s and printable / len(s) > 0.85:
                        line += f'  str="{s[:90]}"'
        except Exception:
            pass
        print(line)

if __name__ == '__main__':
    path = sys.argv[1]
    buf = open(path, 'rb').read()
    r = root(buf)
    print(f'file={path} size={len(buf)} root@{r.pos} vt_fields={r.nfields} tbl_size={r.tbl_size}')
    # root field 0 is the vector of records
    if len(sys.argv) > 2:
        start, n = read_vector_meta(buf, r.fpos(0))
        idx = int(sys.argv[2])
        elem_off = start + idx * 4
        rec_pos = deref_uoffset(buf, elem_off)
        rt = Table(buf, rec_pos)
        print(f'record[{idx}] @{rec_pos} nfields={rt.nfields} tbl_size={rt.tbl_size}')
        dump_table(buf, rec_pos)
    else:
        for i in range(r.nfields):
            fp = r.fpos(i)
            if fp is None:
                continue
            try:
                start, n = read_vector_meta(buf, fp)
                if 0 < n < 100000:
                    print(f'  field[{i}] @ {fp}: VECTOR len={n} elem_start={start}')
                    continue
            except Exception:
                pass
            d = describe_field(buf, r, i)
            print(f'  field[{i}]: {d}')
