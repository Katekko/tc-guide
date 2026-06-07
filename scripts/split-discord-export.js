#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const input = process.argv[2];
const outputDir = process.argv[3] || "raw/split";

if (!input) {
  console.error("Usage: node scripts/split-discord-export.js <export.json> [output-dir]");
  process.exit(1);
}

const channelNames = {
  "1463989887358341314": "new-player-guides",
  "1472343986181111871": "ur-guides",
  "1472344050307960927": "beast-and-soul-mirror-guides",
  "1472344105806856212": "gears-and-stats-guide",
  "1472344172961857700": "team-comp-guides",
  "1474487522087403775": "ur-plus-guide",
  "1499979120099066019": "ur-beast-guide",
  "1505425134616313956": "ex-guide",
  "1505425232004124732": "relic-and-brand-guide",
  "1472345390283100272": "linked-ur-discussion",
  "1472345786242171051": "linked-beast-spirit-discussion",
};

function channelIdFromUrl(url) {
  const match = String(url || "").match(/discord\.com\/channels\/\d+\/(\d+)/);
  return match ? match[1] : "unknown";
}

function slugFor(channelId) {
  return channelNames[channelId] || `channel-${channelId}`;
}

function messageKey(message) {
  return [
    message.pageUrl || "",
    message.timestamp || "",
    message.author || "",
    message.content || "",
  ].join("\n");
}

function cleanAttachments(attachments) {
  return (attachments || []).filter((url) => {
    return !/\/avatars\//.test(url) &&
      !/discord\.com\/assets\//.test(url) &&
      !/cdn\.discordapp\.com\/emojis\//.test(url);
  });
}

function toMarkdown(channelId, messages) {
  const lines = [
    `# ${slugFor(channelId)}`,
    "",
    `Discord channel id: ${channelId}`,
    `Messages: ${messages.length}`,
    "",
  ];

  for (const message of messages) {
    lines.push("## Message");
    if (message.author) lines.push(`Author: ${message.author}`);
    if (message.timestamp) lines.push(`Time: ${message.timestamp}`);
    if (message.pageUrl) lines.push(`Source: ${message.pageUrl}`);
    lines.push("");
    if (message.content) lines.push(message.content, "");

    if (message.embeds && message.embeds.length) {
      lines.push("Embeds:", ...message.embeds.map((item) => `- ${item}`), "");
    }

    if (message.links && message.links.length) {
      lines.push("Links:", ...message.links.map((item) => `- ${item}`), "");
    }

    const attachments = cleanAttachments(message.attachments);
    if (attachments.length) {
      lines.push("Attachments:", ...attachments.map((item) => `- ${item}`), "");
    }

    lines.push("---", "");
  }

  return lines.join("\n");
}

const raw = JSON.parse(fs.readFileSync(input, "utf8"));
const deduped = Array.from(new Map(raw.map((message) => [messageKey(message), message])).values());
const grouped = new Map();

for (const message of deduped) {
  const channelId = channelIdFromUrl(message.pageUrl);
  if (!grouped.has(channelId)) grouped.set(channelId, []);
  grouped.get(channelId).push({
    ...message,
    attachments: cleanAttachments(message.attachments),
  });
}

fs.mkdirSync(outputDir, { recursive: true });

for (const [channelId, messages] of grouped) {
  const slug = slugFor(channelId);
  const jsonPath = path.join(outputDir, `${slug}.json`);
  const mdPath = path.join(outputDir, `${slug}.md`);
  fs.writeFileSync(jsonPath, JSON.stringify(messages, null, 2));
  fs.writeFileSync(mdPath, toMarkdown(channelId, messages));
  console.log(`${messages.length.toString().padStart(3)} ${slug}`);
}
