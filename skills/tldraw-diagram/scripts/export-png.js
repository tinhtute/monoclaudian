// The ops end with white margin rules, so the export adds no padding of its own (matches the MCP screenshot).
const ids=[...editor.getCurrentPageShapeIds()];
const {blob} = await editor.toImage(ids,{format:'png',background:true,padding:0,scale:2,darkMode:false});
const buf = new Uint8Array(await blob.arrayBuffer()); let s=''; for (let i=0;i<buf.length;i+=0x8000) s+=String.fromCharCode(...buf.subarray(i,i+0x8000));
return btoa(s);
