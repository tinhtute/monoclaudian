// Runs an apply_ops "ops" array (the tldraw MCP batch format) in tldraw offline, so one ops file
// draws on both backends. Prepended by tl.sh: const OPS = [...];
// Supported: add (label, box, ellipse) with at; path (open: line, at most 9 points; closed: an oval
// over its bounds, the light-pill pill); resize with scale; connect; remove. Anything else throws.
// A redraw removes only this ops file's own ids, never other shapes on the page.
editor.deleteShapes(OPS.filter((o) => o.id).map((o) => 'shape:' + o.id).filter((t) => editor.getShape(t)));
const rt = (t) => ({type: 'doc', content: String(t ?? '').split('\n').map((l) => ({type: 'paragraph', content: l ? [{type: 'text', text: l}] : []}))});
const sid = (n) => 'shape:' + n;
const results = [];
for (const [i, o] of OPS.entries()) {
  const style = {color: o.color ?? 'black', size: o.size ?? 'm'};
  if (o.op === 'add' && o.kind === 'label') {
    editor.createShape({id: sid(o.id), type: 'text', x: o.at.x, y: o.at.y, props: {...style, richText: rt(o.text), font: 'draw', autoSize: true}});
  } else if (o.op === 'add' && (o.kind === 'box' || o.kind === 'ellipse')) {
    editor.createShape({id: sid(o.id), type: 'geo', x: o.at.x, y: o.at.y, props: {...style, geo: o.kind === 'box' ? 'rectangle' : 'ellipse', w: o.w, h: o.h, fill: o.fill ?? 'none', dash: o.dash ?? 'draw', font: 'draw', richText: rt(o.text), ...(o.align && o.align !== 'center' ? {align: o.align} : {})}});
  } else if (o.op === 'path') {
    const xs = o.points.map((p) => p.x), ys = o.points.map((p) => p.y);
    const x = Math.min(...xs), y = Math.min(...ys);
    if (o.closed) {
      editor.createShape({id: sid(o.id), type: 'geo', x, y, props: {...style, geo: 'oval', w: Math.max(...xs) - x, h: Math.max(...ys) - y, fill: o.fill ?? 'none', dash: o.dash ?? 'draw'}});
    } else {
      if (o.points.length > 9) throw new Error('ops[' + i + ']: an open path has at most 9 points offline');
      const pts = Object.fromEntries(o.points.map((p, k) => ['a' + (k + 1), {id: 'a' + (k + 1), index: 'a' + (k + 1), x: p.x - o.points[0].x, y: p.y - o.points[0].y}]));
      editor.createShape({id: sid(o.id), type: 'line', x: o.points[0].x, y: o.points[0].y, props: {...style, dash: o.dash ?? 'draw', points: pts}});
    }
  } else if (o.op === 'resize' && typeof o.target === 'string' && o.scale) {
    const s = editor.getShape(sid(o.target));
    if (!s) throw new Error('ops[' + i + ']: unknown shape ' + o.target);
    editor.updateShape(s.type === 'text' ? {id: s.id, type: s.type, props: {scale: (s.props.scale ?? 1) * o.scale}} : {id: s.id, type: s.type, props: {w: s.props.w * o.scale, h: s.props.h * o.scale}});
  } else if (o.op === 'connect') {
    const aid = sid(o.id);
    if (editor.getShape(aid)) editor.deleteShapes([aid]);
    editor.createShape({id: aid, type: 'arrow', x: 0, y: 0, props: {color: o.color ?? 'black', dash: o.dash ?? 'draw', size: 'm', font: 'draw', richText: rt(o.text), start: {x: 0, y: 0}, end: {x: 1, y: 1}}});
    const bind = (terminal, to) => ({fromId: aid, toId: sid(to), type: 'arrow', props: {terminal, normalizedAnchor: {x: 0.5, y: 0.5}, isExact: false, isPrecise: false}});
    editor.createBindings([bind('start', o.from), bind('end', o.to)]);
  } else if (o.op === 'remove') {
    editor.deleteShapes(o.targets.map(sid).filter((t) => editor.getShape(t)));
  } else {
    throw new Error('ops[' + i + ']: ' + o.op + (o.kind ? '/' + o.kind : '') + ' is not supported offline');
  }
  results.push(o.id ?? o.op);
}
editor.updateInstanceState({isGridMode: false});
editor.user.updateUserPreferences({colorScheme: 'light'});
editor.zoomToFit();
await helpers.saveDoc();
return {n: editor.getCurrentPageShapeIds().size, applied: results.length, lints: helpers.getLints()};
