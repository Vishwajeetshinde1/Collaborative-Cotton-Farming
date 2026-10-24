(function(){
  const menu=document.querySelector('.menu-toggle'),nav=document.querySelector('.nav-links');
  if(menu&&nav)menu.addEventListener('click',()=>{const open=nav.classList.toggle('open');menu.setAttribute('aria-expanded',String(open));menu.setAttribute('aria-label',open?'Close navigation':'Open navigation');});
  document.querySelectorAll('[data-year]').forEach(el=>el.textContent=new Date().getFullYear());
  const items=document.querySelectorAll('.reveal');
  if('IntersectionObserver' in window){const observer=new IntersectionObserver(entries=>entries.forEach(entry=>{if(entry.isIntersecting){entry.target.classList.add('in-view');observer.unobserve(entry.target);}}),{threshold:.12});items.forEach(el=>observer.observe(el));}else items.forEach(el=>el.classList.add('in-view'));
  window.CCFUI={
    escape(value){return String(value??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));},
    num(value,digits=0){return new Intl.NumberFormat('en-IN',{maximumFractionDigits:digits}).format(Number(value)||0);},
    money(value){return new Intl.NumberFormat('en-IN',{style:'currency',currency:'INR',maximumFractionDigits:0}).format(Number(value)||0);},
    date(value){if(!value)return '—';const d=new Date(value+'T12:00:00');return isNaN(d)?this.escape(value):d.toLocaleDateString('en-IN',{day:'2-digit',month:'short',year:'numeric'});},
    toast(message,type='success'){let el=document.querySelector('.toast');if(el)el.remove();el=document.createElement('div');el.className='toast'+(type==='error'?' error':'');el.textContent=message;document.body.append(el);setTimeout(()=>el.remove(),3500);},
    initials(name=''){return name.trim().split(/\s+/).slice(0,2).map(s=>s[0]||'').join('').toUpperCase()||'CF';},
    baseTraceURL(){return new URL('traceability.html',location.href).href.split('#')[0];}
  };
})();
