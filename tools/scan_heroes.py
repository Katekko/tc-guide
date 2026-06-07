import sys; sys.argv=['x']
exec(open('tools/fbexplore.py').read().split("if __name__")[0])
buf=open('apk-extract/bundle_flatbuffer/assets/assets/bundle_flatbuffer/native/2d/2dee2828-395e-4798-b8aa-4c46371eef89.ft','rb').read()
r=root(buf); start,n=read_vector_meta(buf,r.fpos(0))
def fstr(t,i):
    fp=t.fpos(i)
    if fp is None: return ''
    try:
        tg=deref_uoffset(buf,fp); ln=u32(buf,tg)
        if 0<=ln<4000: return buf[tg+4:tg+4+ln].decode('utf-8','replace')
    except: pass
    return ''
def fint(t,i):
    fp=t.fpos(i); return u32(buf,fp) if fp else None
for k in range(n):
    rec=deref_uoffset(buf,start+k*4); t=Table(buf,rec)
    hid=fint(t,0); name=fstr(t,40); title=fstr(t,1); skill=fstr(t,2)
    mark = ' <<< JEANNE' if ('贞德' in name+title+fstr(t,43)) else ''
    print(f'[{k:2}] id={hid} name="{name}" title="{title}" skill="{skill}"{mark}')
