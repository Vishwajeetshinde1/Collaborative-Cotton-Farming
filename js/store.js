/* Shared browser data store. No database/server connection in this prototype. */
(function(){
  const KEY='ccf-collaborative-cotton-v2';
  const clone=value=>JSON.parse(JSON.stringify(value));
  function defaults(){return {...clone(window.CCF_DEMO_DATA),createdAt:new Date().toISOString().slice(0,10),version:2};}
  function load(){try{const raw=localStorage.getItem(KEY);if(!raw)return defaults();const saved=JSON.parse(raw);if(!Array.isArray(saved.farmers)||!Array.isArray(saved.lots))return defaults();return {...defaults(),...saved,settings:{...defaults().settings,...saved.settings}};}catch{return defaults();}}
  let state=load();
  function save(){try{localStorage.setItem(KEY,JSON.stringify(state));window.dispatchEvent(new CustomEvent('ccf:data-updated',{detail:state}));return true;}catch(e){console.error(e);return false;}}
  function all(){return state;}
  function reset(){state=defaults();save();return state;}
  function update(patch){state={...state,...patch};save();return state;}
  function importJSON(data){if(!data||!Array.isArray(data.farmers)||!Array.isArray(data.lots)||!data.metrics)throw new Error('Invalid CCF backup: expected farmers, lots and metrics.');state={...defaults(),...data,settings:{...defaults().settings,...data.settings}};save();return state;}
  window.CCFStore={KEY,all,save,reset,update,importJSON,clone,farmer:id=>state.farmers.find(f=>f.id===id),lot:id=>state.lots.find(l=>l.id===id),bale:id=>{for(const lot of state.lots){const bale=(lot.bales||[]).find(b=>b.id===id);if(bale)return {lot,bale};}return null;}};
})();
