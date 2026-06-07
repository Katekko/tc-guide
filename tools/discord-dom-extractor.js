/*
 * One-time Discord Web DOM extractor.
 *
 * Usage:
 * 1. Open Discord Web in your browser and go to the channel/thread to capture.
 * 2. Open DevTools Console.
 * 3. Paste this entire file and press Enter.
 * 4. Use the small "TC Extractor" panel that appears on the page.
 *
 * This only reads messages currently loaded in your browser DOM. It does not
 * bypass Discord permissions and it does not call Discord APIs.
 */
(function tcDiscordDomExtractor() {
  const STORAGE_KEY = "tc_discord_dom_extract_v1";
  const PANEL_ID = "tc-discord-extractor-panel";
  const storage = getStorage();

  const previousPanel = document.getElementById(PANEL_ID);
  if (previousPanel) previousPanel.remove();

  const state = loadState();

  function loadState() {
    try {
      if (!storage) return { messages: [] };
      const raw = storage.getItem(STORAGE_KEY);
      const parsed = raw ? JSON.parse(raw) : { messages: [] };
      return {
        messages: Array.isArray(parsed.messages) ? parsed.messages : [],
      };
    } catch {
      return { messages: [] };
    }
  }

  function saveState() {
    if (!storage) return;
    storage.setItem(STORAGE_KEY, JSON.stringify(state));
  }

  function getStorage() {
    try {
      const candidate = window.localStorage || globalThis.localStorage;
      if (!candidate) return null;
      const testKey = `${STORAGE_KEY}_test`;
      candidate.setItem(testKey, "1");
      candidate.removeItem(testKey);
      return candidate;
    } catch {
      return null;
    }
  }

  function textOf(node) {
    return (node && node.textContent ? node.textContent : "").replace(/\s+/g, " ").trim();
  }

  function attr(node, name) {
    const value = node && typeof node.getAttribute === "function" ? node.getAttribute(name) : "";
    return value || "";
  }

  function unique(values) {
    return Array.from(new Set(values.filter(Boolean)));
  }

  function messageIdFrom(node) {
    const listId = attr(node, "data-list-item-id");
    const idMatch = listId.match(/chat-messages___([^_]+)/);
    if (idMatch) return idMatch[1];

    const id = attr(node, "id");
    const domIdMatch = id.match(/chat-messages-([^_]+)/);
    if (domIdMatch) return domIdMatch[1];

    const timestamp = node.querySelector("time")?.dateTime || "";
    return `${timestamp}:${textOf(node).slice(0, 120)}`;
  }

  function findMessageNodes() {
    const selectors = [
      '[data-list-item-id^="chat-messages___"]',
      '[id^="chat-messages-"]',
      'li[class*="messageListItem"]',
      'div[role="article"]',
    ];

    const nodes = selectors.flatMap((selector) => Array.from(document.querySelectorAll(selector)));
    return unique(nodes.map((node) => node)).filter((node) => textOf(node));
  }

  function extractMessage(node) {
    const authorNode =
      node.querySelector('[class*="username"]') ||
      node.querySelector('[class*="headerText"] span') ||
      node.querySelector('h3 span[id^="message-username"]');

    const contentNodes = Array.from(
      node.querySelectorAll('[id^="message-content-"], [class*="markup"]')
    );

    const content = unique(contentNodes.map(textOf)).join("\n\n");
    const embeds = unique(
      Array.from(node.querySelectorAll('[class*="embed"]')).map(textOf)
    );

    const links = unique(
      Array.from(node.querySelectorAll("a[href]")).map((link) => link.href)
    );

    const attachments = unique(
      Array.from(node.querySelectorAll("img[src], video[src], audio[src]")).map((media) => media.src)
    ).filter((src) => !src.startsWith("data:"));

    return {
      id: messageIdFrom(node),
      author: textOf(authorNode),
      timestamp: node.querySelector("time")?.dateTime || "",
      content,
      embeds,
      links,
      attachments,
      capturedAt: new Date().toISOString(),
      pageUrl: window.location.href,
    };
  }

  function captureVisible() {
    const existing = new Map(state.messages.map((message) => [message.id, message]));
    const extracted = findMessageNodes().map(extractMessage).filter((message) => {
      return message.content || message.embeds.length || message.links.length || message.attachments.length;
    });

    for (const message of extracted) {
      existing.set(message.id, { ...existing.get(message.id), ...message });
    }

    const before = state.messages.length;
    state.messages = Array.from(existing.values()).sort((a, b) => {
      return String(a.timestamp || a.id).localeCompare(String(b.timestamp || b.id));
    });
    saveState();
    renderStatus(`Captured ${state.messages.length - before} new messages. Total: ${state.messages.length}.`);
  }

  function clearCaptured() {
    if (!window.confirm("Clear captured messages from this browser?")) return;
    state.messages = [];
    saveState();
    renderStatus("Cleared captured messages.");
  }

  function toMarkdown() {
    const lines = [
      "# Discord Extract",
      "",
      `Source URL: ${window.location.href}`,
      `Exported: ${new Date().toISOString()}`,
      `Messages: ${state.messages.length}`,
      "",
    ];

    for (const message of state.messages) {
      lines.push("## Message");
      if (message.author) lines.push(`Author: ${message.author}`);
      if (message.timestamp) lines.push(`Time: ${message.timestamp}`);
      lines.push(`Source: ${message.pageUrl}`);
      lines.push("");
      if (message.content) lines.push(message.content, "");
      if (message.embeds.length) lines.push("Embeds:", ...message.embeds.map((item) => `- ${item}`), "");
      if (message.links.length) lines.push("Links:", ...message.links.map((item) => `- ${item}`), "");
      if (message.attachments.length) lines.push("Attachments:", ...message.attachments.map((item) => `- ${item}`), "");
      lines.push("---", "");
    }

    return lines.join("\n");
  }

  function download(filename, content, type) {
    const blob = new Blob([content], { type });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = filename;
    link.click();
    URL.revokeObjectURL(url);
  }

  async function copyMarkdown() {
    await navigator.clipboard.writeText(toMarkdown());
    renderStatus("Copied Markdown to clipboard.");
  }

  function exportMarkdown() {
    download("discord-extract.md", toMarkdown(), "text/markdown;charset=utf-8");
    renderStatus("Downloaded Markdown.");
  }

  function exportJson() {
    download(
      "discord-extract.json",
      JSON.stringify(state.messages, null, 2),
      "application/json;charset=utf-8"
    );
    renderStatus("Downloaded JSON.");
  }

  function createButton(label, onClick) {
    const button = document.createElement("button");
    button.textContent = label;
    button.addEventListener("click", onClick);
    button.style.cssText = [
      "display:block",
      "width:100%",
      "margin:6px 0",
      "padding:7px 8px",
      "border:1px solid #555",
      "border-radius:6px",
      "background:#2f3136",
      "color:#fff",
      "cursor:pointer",
      "font:12px system-ui,sans-serif",
      "text-align:left",
    ].join(";");
    return button;
  }

  function renderStatus(message) {
    const status = document.getElementById(`${PANEL_ID}-status`);
    if (status) status.textContent = message;
  }

  function createPanel() {
    const panel = document.createElement("div");
    panel.id = PANEL_ID;
    panel.style.cssText = [
      "position:fixed",
      "right:16px",
      "bottom:16px",
      "z-index:2147483647",
      "width:220px",
      "padding:12px",
      "border:1px solid #555",
      "border-radius:8px",
      "background:#202225",
      "color:#fff",
      "box-shadow:0 8px 24px rgba(0,0,0,.35)",
      "font:12px system-ui,sans-serif",
    ].join(";");

    const title = document.createElement("div");
    title.textContent = "TC Extractor";
    title.style.cssText = "font-weight:700;margin-bottom:8px;";

    const status = document.createElement("div");
    status.id = `${PANEL_ID}-status`;
    status.textContent = storage
      ? `Loaded. Stored messages: ${state.messages.length}.`
      : "Loaded without persistent storage. Export before refreshing Discord.";
    status.style.cssText = "margin-bottom:8px;color:#c9c9c9;line-height:1.35;";

    panel.append(
      title,
      status,
      createButton("Capture visible messages", captureVisible),
      createButton("Copy Markdown", copyMarkdown),
      createButton("Download Markdown", exportMarkdown),
      createButton("Download JSON", exportJson),
      createButton("Clear captured data", clearCaptured)
    );

    document.body.appendChild(panel);
  }

  createPanel();
})();
