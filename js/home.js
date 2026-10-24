(function(){
  const fmt=(n,key)=>new Intl.NumberFormat('en-IN',{maximumFractionDigits:key==='acres'?1:0}).format(n);
  const animateValue=(el,target)=>{
    if(el.dataset.counted==='yes'){el.textContent=fmt(target,el.dataset.metric);return;}
    el.dataset.counted='yes';
    const duration=1250,start=performance.now(),from=0;
    const tick=now=>{const p=Math.min(1,(now-start)/duration),ease=1-Math.pow(1-p,4);el.textContent=fmt(Math.round(from+(target-from)*ease),el.dataset.metric);if(p<1)requestAnimationFrame(tick);};
    requestAnimationFrame(tick);
  };
  const render=()=>{const s=window.CCFStore.all();document.querySelectorAll('[data-metric]').forEach(el=>{const key=el.dataset.metric;const target=Number(s.metrics?.[key])||0;if(!el.dataset.counted&&'IntersectionObserver'in window){const observer=new IntersectionObserver(entries=>{if(entries.some(e=>e.isIntersecting)){animateValue(el,target);observer.disconnect();}},{threshold:.25});observer.observe(el);}else animateValue(el,target);});const flag=document.querySelector('#metric-status');if(flag)flag.textContent=s.metricsAreDemo===false?'USER-ENTERED FIGURES':'ILLUSTRATIVE DEMO DATA';};
  render();window.addEventListener('ccf:data-updated',()=>{document.querySelectorAll('[data-metric]').forEach(el=>{el.dataset.counted='yes';});render();});
})();
