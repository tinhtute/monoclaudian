# Style: light-pill (default)

High-level topology only: the main components and how they connect. One idea per diagram. Every rule below is an `apply_ops` op; `assets/architecture.ops.json` is the worked example.

## Canvas

- Light theme; page y grows downward.
- Title: `{op:'add', kind:'label', id:'title', at:{x:40,y:20}, text, size:'xl'}`.
- Subtitle: `{op:'add', kind:'label', id:'sub', at:{x:42,y:80}, text, color:'grey', size:'s'}`, one sentence.
- Band (2–4 per diagram) at height `y`, three ops:
  - rule: `{op:'path', id:'<b>_l', points:[{x:40,y},{x:40+W,y}], color:'grey', dash:'solid', size:'s'}`
  - dot: `{op:'add', kind:'ellipse', id:'<b>_d', at:{x:48,y:y+30}, w:16, h:16, color:<role>, fill:'fill', dash:'solid', size:'s'}`
  - label: `{op:'add', kind:'label', id:'<b>_t', at:{x:74,y:y+18}, text, size:'m'}`
- Keep the left 200px clear for band labels.
- End with an invisible bottom margin so the export does not clip card borders: `{op:'path', id:'margin', points:[{x:40,y:<lowest card bottom + 50>},{x:40+W,y:<same>}], color:'white', dash:'solid', size:'s'}`.

## Cards

- Card: `{op:'add', kind:'box', id, at:{x,y}, w, h, text:'\n' + lines.join('\n'), color:'black', fill:'semi', dash:'draw', size:'m'}`.
  - 2–4 short lines, no sentences; the leading `\n` leaves room for the pill.
  - Width fits the longest line without wrapping (≈13px per char at size `m`); height ≈ 50 + 25 per line.
- Pill tag straddling the card's top border, left-aligned, as two ops:
  - oval: `{op:'add', kind:'ellipse', id:'<id>_tag', at:{x:x+14,y:y-17}, w:tag.length*10+52, h:34, color:<role>, fill:'solid', dash:'solid', size:'s'}`
  - text: `{op:'add', kind:'label', id:'<id>_tagt', at:{x:x+30,y:y-13}, text:'● '+tag, color:<role>, size:'s'}`
  - Keep the text out of the oval: a geo shape grows to fit its own label (≈56px at size `s`), so a 34px pill with text inside would grow.
  - Place both with `at`, never `relation`/`target`: relative placement nudges a shape off the card it straddles.

## Color

One color per role or flow; the same color on the pill, its band dot and the arrows that leave the card.

| Role | Color |
|---|---|
| user, entry, evidence | `light-red` |
| router, binary, managed docs | `blue` |
| main path, source, success | `green` |
| bug, plan, consumer data | `orange` |
| host, reads/writes, read-only | `violet` |
| resume, loop back | `light-blue` |
| learn, retro | `yellow` |
| guard, gate, failure | `red` |

## Arrows

- `{op:'connect', id:'arr_<from>_<to>', from, to, color:<source role>, dash:'draw', text}`; use `dash:'dashed'` for gates and loops back.
- Label with one verb or two words (`install`, `reads`, `gate commits`).
- Arrows bind to both cards and route straight: no bend, elbow or anchor. Put a card directly under the card that feeds it, and move cards rather than letting an arrow cross another card or hide under a pill.

## Checks before delivery

- Every `apply_ops` op result succeeded. Notes that a pill overlaps its card are expected; a note that a shape grew to fit its text means it needs more `w`/`h`.
- The screenshot shows no wrapped pill text, no card overlap, and every arrowhead visible.
