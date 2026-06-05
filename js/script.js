(function(){
  'use strict';

  /* Header scroll */
  const header = document.querySelector('header');
  if(header){
    window.addEventListener('scroll',()=>header.classList.toggle('scrolled',window.scrollY>60),{passive:true});
  }

  /* Mobile nav */
  const hamburger = document.querySelector('.hamburger');
  const nav = document.querySelector('nav');
  if(hamburger && nav){
    hamburger.addEventListener('click',()=>{
      hamburger.classList.toggle('open');
      nav.classList.toggle('open');
      document.body.style.overflow = nav.classList.contains('open')?'hidden':'';
    });
    nav.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>{
      hamburger.classList.remove('open');
      nav.classList.remove('open');
      document.body.style.overflow='';
    }));
  }

  /* Feature cards animation */
  const featureCards = document.querySelectorAll('.feature-card');
  if(featureCards.length){
    const obs = new IntersectionObserver(entries=>{
      entries.forEach(e=>{
        if(e.isIntersecting){
          featureCards.forEach((c,i)=>setTimeout(()=>c.classList.add('show'),i*120));
          obs.disconnect();
        }
      });
    },{threshold:0.15});
    const section = document.querySelector('.about-features');
    if(section) obs.observe(section);
  }

  /* Stats counter */
  const stats = document.querySelectorAll('.stat h3[data-count]');
  if(stats.length){
    const countUp = el=>{
      const target=+el.dataset.count, suffix=el.dataset.suffix||'';
      let start=0; const step=target/60;
      const timer=setInterval(()=>{
        start=Math.min(start+step,target);
        el.textContent=Math.floor(start)+suffix;
        if(start>=target) clearInterval(timer);
      },20);
    };
    const strip = document.querySelector('.stats-strip');
    if(strip){
      new IntersectionObserver(entries=>{
        entries.forEach(e=>{if(e.isIntersecting){stats.forEach(countUp);}});
      },{threshold:0.5}).observe(strip);
    }
  }

  /* Service cards stagger */
  const cards = document.querySelectorAll('.card');
  if(cards.length){
    cards.forEach((c,i)=>{
      c.style.opacity='0';c.style.transform='translateY(28px)';
      c.style.transition=`opacity .5s ease ${i*.08}s,transform .5s ease ${i*.08}s,border-color .35s,box-shadow .35s`;
    });
    const cardObs=new IntersectionObserver(entries=>{
      entries.forEach(e=>{if(e.isIntersecting){e.target.style.opacity='1';e.target.style.transform='translateY(0)';}});
    },{threshold:0.1});
    cards.forEach(c=>cardObs.observe(c));
  }

  /* Gallery filter tabs */
  const tabBtns = document.querySelectorAll('.tab-btn');
  const galleryItems = document.querySelectorAll('.gallery-item');
  if(tabBtns.length){
    tabBtns.forEach(btn=>{
      btn.addEventListener('click',()=>{
        tabBtns.forEach(b=>b.classList.remove('active'));
        btn.classList.add('active');
        const filter = btn.dataset.filter;
        galleryItems.forEach(item=>{
          if(filter==='all' || item.dataset.type===filter){
            item.classList.remove('hidden');
          } else {
            item.classList.add('hidden');
          }
        });
      });
    });
  }

  /* Gallery scroll reveal */
  const gItems = document.querySelectorAll('.gallery-item');
  if(gItems.length){
    const gObs = new IntersectionObserver(entries=>{
      entries.forEach((e,i)=>{
        if(e.isIntersecting) setTimeout(()=>e.target.classList.add('show'),i*80);
      });
    },{threshold:0.1});
    gItems.forEach(i=>gObs.observe(i));
  }

  /* Play overlay click */
  document.querySelectorAll('.play-overlay').forEach(overlay=>{
    overlay.addEventListener('click',()=>{
      const video = overlay.closest('.video-wrap')?.querySelector('video');
      if(video){ overlay.style.display='none'; video.play(); }
    });
  });

  /* LOCAL upload preview in gallery */
  const fileInput = document.getElementById('galleryUpload');
  const dropZone  = document.getElementById('uploadZone');
  if(fileInput && dropZone){
    dropZone.addEventListener('click',()=>fileInput.click());
    dropZone.addEventListener('dragover',e=>{e.preventDefault();dropZone.style.borderColor='#ff3c00';});
    dropZone.addEventListener('dragleave',()=>dropZone.style.borderColor='');
    dropZone.addEventListener('drop',e=>{
      e.preventDefault();dropZone.style.borderColor='';
      handleFiles(e.dataTransfer.files);
    });
    fileInput.addEventListener('change',()=>handleFiles(fileInput.files));

    function handleFiles(files){
      const grid = document.getElementById('galleryGrid');
      Array.from(files).forEach(file=>{
        const isVideo = file.type.startsWith('video');
        const url = URL.createObjectURL(file);
        const item = document.createElement('div');
        item.className='gallery-item show';
        item.dataset.type = isVideo?'video':'photo';
        if(isVideo){
          item.innerHTML=`
            <div class="video-wrap">
              <video src="${url}" controls style="max-height:300px;width:100%;object-fit:cover"></video>
              <span class="video-badge">Video</span>
            </div>
            <div class="gallery-caption"><h4>${file.name}</h4><p>Just uploaded</p></div>`;
        } else {
          item.innerHTML=`
            <div class="img-wrap">
              <img src="${url}" alt="${file.name}" loading="lazy">
              <div class="img-overlay"><span>${file.name}</span></div>
            </div>
            <div class="gallery-caption"><h4>${file.name}</h4><p>Just uploaded</p></div>`;
        }
        grid.prepend(item);
      });
    }
  }

  /* Contact form EmailJS */
  const form = document.getElementById('contactForm');
  if(form){
    form.addEventListener('submit',e=>{
      e.preventDefault();
      const name=document.getElementById('from_name').value.trim();
      const email=document.getElementById('from_email').value.trim();
      const message=document.getElementById('message').value.trim();
      if(!name){showToast('⚠️ Please enter your name.','error');return;}
      if(!email||!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)){showToast('⚠️ Please enter a valid email.','error');return;}
      if(!message){showToast('⚠️ Please write your message.','error');return;}
      const btn=document.getElementById('submitBtn');
      btn.textContent='Sending…';btn.classList.add('loading');btn.disabled=true;
      emailjs.send('service_0koaxpo','template_37lyyvo',{
        from_name:name,from_email:email,
        phone:document.getElementById('phone').value.trim()||'Not provided',
        service:document.getElementById('service').value||'Not selected',
        message,reply_to:email
      }).then(()=>{
        showToast('✅ Message sent! We\'ll contact you soon.','success');
        form.reset();
      }).catch(()=>{
        showToast('❌ Failed to send. Please call or WhatsApp us.','error');
      }).finally(()=>{
        btn.textContent='Send Message 🚀';btn.classList.remove('loading');btn.disabled=false;
      });
    });
  }

  /* Toast */
  function showToast(msg,type='success'){
    let t=document.getElementById('toast');
    if(!t){t=document.createElement('div');t.id='toast';document.body.appendChild(t);}
    t.textContent=msg;t.className='toast '+type;t.classList.add('show');
    setTimeout(()=>t.classList.remove('show'),5000);
  }

})();
