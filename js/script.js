(function () {
  'use strict';

  /* =============================================
     BUG FIXES & IMPROVEMENTS IN THIS FILE:
     1. Hamburger: aria-expanded toggled correctly
     2. Stats counter: fires only once (disconnect after trigger)
     3. Play overlay: keyboard accessible (Enter/Space)
     4. Gallery filter tabs: aria-selected toggled
     5. EmailJS: guard if emailjs not loaded (contact page only)
     6. Toast: uses aria-live region for screen readers
     7. Upload zone: keyboard accessible (Enter/Space triggers click)
  ============================================= */

  /* ===== HEADER SCROLL ===== */
  const header = document.querySelector('header');
  if (header) {
    window.addEventListener('scroll', () =>
      header.classList.toggle('scrolled', window.scrollY > 60),
      { passive: true }
    );
  }

  /* ===== MOBILE NAV ===== */
  const hamburger = document.querySelector('.hamburger');
  const nav = document.querySelector('nav');
  if (hamburger && nav) {
    hamburger.addEventListener('click', () => {
      const isOpen = nav.classList.toggle('open');
      hamburger.classList.toggle('open', isOpen);
      // BUG FIX: keep aria-expanded in sync
      hamburger.setAttribute('aria-expanded', String(isOpen));
      document.body.style.overflow = isOpen ? 'hidden' : '';
    });
    nav.querySelectorAll('a').forEach(a => a.addEventListener('click', () => {
      hamburger.classList.remove('open');
      nav.classList.remove('open');
      hamburger.setAttribute('aria-expanded', 'false');
      document.body.style.overflow = '';
    }));
  }

  /* ===== FEATURE CARDS ANIMATION ===== */
  const featureCards = document.querySelectorAll('.feature-card');
  if (featureCards.length) {
    const section = document.querySelector('.about-features');
    if (section) {
      const obs = new IntersectionObserver(entries => {
        entries.forEach(e => {
          if (e.isIntersecting) {
            featureCards.forEach((c, i) => setTimeout(() => c.classList.add('show'), i * 120));
            obs.disconnect(); // only animate once
          }
        });
      }, { threshold: 0.15 });
      obs.observe(section);
    }
  }

  /* ===== STATS COUNTER ===== */
  const stats = document.querySelectorAll('.stat h3[data-count]');
  if (stats.length) {
    let animated = false; // BUG FIX: prevent re-running on every scroll

    const countUp = el => {
      const target = +el.dataset.count;
      const suffix = el.dataset.suffix || '';
      let start = 0;
      const step = target / 60;
      const timer = setInterval(() => {
        start = Math.min(start + step, target);
        el.textContent = Math.floor(start) + suffix;
        if (start >= target) clearInterval(timer);
      }, 20);
    };

    const strip = document.querySelector('.stats-strip');
    if (strip) {
      const statsObs = new IntersectionObserver(entries => {
        entries.forEach(e => {
          if (e.isIntersecting && !animated) {
            animated = true;
            stats.forEach(countUp);
            statsObs.disconnect(); // BUG FIX: disconnect so it runs only once
          }
        });
      }, { threshold: 0.5 });
      statsObs.observe(strip);
    }
  }

  /* ===== SERVICE CARDS STAGGER ===== */
  const cards = document.querySelectorAll('.card');
  if (cards.length) {
    cards.forEach((c, i) => {
      c.style.opacity = '0';
      c.style.transform = 'translateY(28px)';
      c.style.transition = `opacity .5s ease ${i * .08}s,transform .5s ease ${i * .08}s,border-color .35s,box-shadow .35s`;
    });
    const cardObs = new IntersectionObserver(entries => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          e.target.style.opacity = '1';
          e.target.style.transform = 'translateY(0)';
        }
      });
    }, { threshold: 0.1 });
    cards.forEach(c => cardObs.observe(c));
  }

  /* ===== GALLERY FILTER TABS ===== */
  const tabBtns = document.querySelectorAll('.tab-btn');
  const galleryItems = document.querySelectorAll('.gallery-item');
  if (tabBtns.length) {
    tabBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        tabBtns.forEach(b => {
          b.classList.remove('active');
          b.setAttribute('aria-selected', 'false'); // BUG FIX: aria-selected sync
        });
        btn.classList.add('active');
        btn.setAttribute('aria-selected', 'true');
        const filter = btn.dataset.filter;
        galleryItems.forEach(item => {
          const show = filter === 'all' || item.dataset.type === filter;
          item.classList.toggle('hidden', !show);
        });
      });
    });
  }

  /* ===== GALLERY SCROLL REVEAL ===== */
  const gItems = document.querySelectorAll('.gallery-item');
  if (gItems.length) {
    const gObs = new IntersectionObserver(entries => {
      entries.forEach((e, i) => {
        if (e.isIntersecting) setTimeout(() => e.target.classList.add('show'), i * 80);
      });
    }, { threshold: 0.1 });
    gItems.forEach(i => gObs.observe(i));
  }

  /* ===== PLAY OVERLAY CLICK & KEYBOARD ===== */
  document.querySelectorAll('.play-overlay').forEach(overlay => {
    const handlePlay = () => {
      const video = overlay.closest('.video-wrap')?.querySelector('video');
      if (video) {
        overlay.style.display = 'none';
        video.play().catch(() => {}); // BUG FIX: catch promise rejection silently
      }
    };
    overlay.addEventListener('click', handlePlay);
    // BUG FIX: keyboard accessibility for play button
    overlay.addEventListener('keydown', e => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); handlePlay(); }
    });
  });

  /* ===== LOCAL UPLOAD PREVIEW IN GALLERY ===== */
  const fileInput = document.getElementById('galleryUpload');
  const dropZone = document.getElementById('uploadZone');
  if (fileInput && dropZone) {
    // BUG FIX: keyboard accessible upload zone
    dropZone.addEventListener('click', () => fileInput.click());
    dropZone.addEventListener('keydown', e => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); fileInput.click(); }
    });

    dropZone.addEventListener('dragover', e => {
      e.preventDefault();
      dropZone.style.borderColor = '#ff3c00';
    });
    dropZone.addEventListener('dragleave', () => dropZone.style.borderColor = '');
    dropZone.addEventListener('drop', e => {
      e.preventDefault();
      dropZone.style.borderColor = '';
      handleFiles(e.dataTransfer.files);
    });
    fileInput.addEventListener('change', () => handleFiles(fileInput.files));

    function handleFiles(files) {
      const grid = document.getElementById('galleryGrid');
      if (!grid) return;
      Array.from(files).forEach(file => {
        const isVideo = file.type.startsWith('video');
        // BUG FIX: revoke old object URLs to prevent memory leaks
        const url = URL.createObjectURL(file);
        const item = document.createElement('div');
        item.className = 'gallery-item show';
        item.dataset.type = isVideo ? 'video' : 'photo';
        const safeName = file.name.replace(/</g, '&lt;').replace(/>/g, '&gt;');
        if (isVideo) {
          item.innerHTML = `
            <div class="video-wrap">
              <video src="${url}" controls style="max-height:300px;width:100%;object-fit:cover" aria-label="${safeName}"></video>
              <span class="video-badge">Video</span>
            </div>
            <div class="gallery-caption"><h4>${safeName}</h4><p>Just uploaded</p></div>`;
        } else {
          item.innerHTML = `
            <div class="img-wrap">
              <img src="${url}" alt="${safeName}" loading="lazy">
              <div class="img-overlay"><span>${safeName}</span></div>
            </div>
            <div class="gallery-caption"><h4>${safeName}</h4><p>Just uploaded</p></div>`;
        }
        grid.prepend(item);
        // Revoke URL after some time to free memory
        setTimeout(() => URL.revokeObjectURL(url), 60000);
      });
    }
  }

  /* ===== CONTACT FORM — EmailJS ===== */
  const form = document.getElementById('contactForm');
  if (form) {
    form.addEventListener('submit', e => {
      e.preventDefault();

      // BUG FIX: guard against emailjs not being loaded
      if (typeof emailjs === 'undefined') {
        showToast('❌ Email service not available. Please call or WhatsApp us.', 'error');
        return;
      }

      const name = document.getElementById('from_name')?.value.trim();
      const email = document.getElementById('from_email')?.value.trim();
      const message = document.getElementById('message')?.value.trim();

      if (!name) { showToast('⚠️ Please enter your name.', 'error'); return; }
      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        showToast('⚠️ Please enter a valid email.', 'error'); return;
      }
      if (!message) { showToast('⚠️ Please write your message.', 'error'); return; }

      const btn = document.getElementById('submitBtn');
      if (btn) { btn.textContent = 'Sending…'; btn.classList.add('loading'); btn.disabled = true; }

      emailjs.send('service_0koaxpo', 'template_37lyyvo', {
        from_name: name,
        from_email: email,
        phone: document.getElementById('phone')?.value.trim() || 'Not provided',
        service: document.getElementById('service')?.value || 'Not selected',
        message,
        reply_to: email
      }).then(() => {
        showToast('✅ Message sent! We\'ll contact you soon.', 'success');
        form.reset();
      }).catch(err => {
        console.error('EmailJS error:', err);
        showToast('❌ Failed to send. Please call or WhatsApp us.', 'error');
      }).finally(() => {
        if (btn) { btn.textContent = 'Send Message 🚀'; btn.classList.remove('loading'); btn.disabled = false; }
      });
    });
  }

  /* ===== TOAST ===== */
  function showToast(msg, type = 'success') {
    // BUG FIX: reuse existing #toast if present, otherwise create
    let t = document.getElementById('toast');
    if (!t) {
      t = document.createElement('div');
      t.id = 'toast';
      t.setAttribute('role', 'alert');
      t.setAttribute('aria-live', 'polite');
      document.body.appendChild(t);
    }
    t.textContent = msg;
    t.className = 'toast ' + type;
    t.classList.add('show');
    setTimeout(() => t.classList.remove('show'), 5000);
  }

})();
