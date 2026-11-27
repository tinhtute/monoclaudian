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
- Pad the export 32px on every side with two invisible rules, since the screenshot crops tight to the shapes:
  - first op: `{op:'path', id:'margin_top', points:[{x:8,y:-12},{x:72+W,y:-12}], color:'white', dash:'solid', size:'s'}`
  - last op: `{op:'path', id:'margin', points:[{x:8,y:<lowest card bottom + 32>},{x:72+W,y:<same>}], color:'white', dash:'solid', size:'s'}`

## Cards

- Card: `{op:'add', kind:'box', id, at:{x,y}, w, h, text:'\n' + lines.join('\n'), align:'start', color:'black', fill:'semi', dash:'draw', size:'m'}`.
  - 2–4 short lines, no sentences; the leading `\n` leaves room for the pill.
  - `align:'start'` (with `at`) left-aligns the text. Vertical alignment has no op and stays middle, so text reads top-aligned only when it fills the card: give cards in one row the same line count, padding a short card with a trailing `\n`.
  - Width fits the longest line without wrapping (≈13px per char at size `m`); height ≈ 50 + 25 per line.
- Pill tag straddling the card's top border, left-aligned, as three ops:
  - oval: a closed path tracing a stadium (straight sides, round ends): `{op:'path', id:'<id>_tag', points:<stadium>, closed:true, fill:'solid', color:<role>, dash:'solid', size:'s'}`, box `x+12, y-16`, `w = tag.length*10 + 40`, `h = 30`. Trace it as two half circles of radius 15, 11 points each; `assets/architecture.ops.json` has every pill's points. Not `kind:'ellipse'`: its pointed ends clip longer tags, and apply_ops has no oval geo.
  - text: `{op:'add', kind:'label', id:'<id>_tagt', at:{x:x+24,y:y-14}, text:'● '+tag, color:<role>, size:'s'}`
  - scale: `{op:'resize', target:'<id>_tagt', scale:0.9}` right after the text.
  - Keep the text out of the oval: a geo shape grows to fit its own label (≈56px at size `s`).
  - Place all three with `at` or points, never `relation`/`target`: relative placement nudges a shape off the card it straddles.

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
- Keep each label on its shaft, in black: when a shaft is shorter than its label width + 40, apply_ops moves the label beside the arrow as its own shape `<arrow id>-label` in the arrow's color. Leave ≥150px between stacked cards; the result line for that arrow then has no `beside it`.
- Arrows bind to both cards and route straight: no bend, elbow or anchor. Put a card directly under the card that feeds it, and move cards rather than letting an arrow cross another card or hide under a pill.

## Checks before delivery

- Every `apply_ops` op result succeeded. Notes that a pill overlaps its card are expected; a note that a shape grew to fit its text means it needs more `w`/`h`; a `beside it` on a connect result means that arrow needs a longer shaft.
- The screenshot shows no wrapped pill text, no card overlap, and every arrowhead visible.
