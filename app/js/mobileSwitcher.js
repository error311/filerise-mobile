// public/js/mobileSwitcher.js
(function () {
  try {
    const hasParam  = /[?&]frapp=1([&#]|$)/.test(location.href);
    const hasCookie = document.cookie.split('; ').some(c => c.startsWith('fr_inapp=1'));
    const inCap     = typeof window.Capacitor !== 'undefined' || navigator.userAgent.includes('FileRiseMobile');

    // If we arrived with the flag once, persist for 30 days so login/redirects keep the FAB
    if (hasParam) {
      document.cookie = 'fr_inapp=1; path=/; max-age=' + (60*60*24*30) + '; SameSite=Lax';
      // strip only the flag from the URL (optional polish)
      try {
        const u = new URL(location.href);
        u.searchParams.delete('frapp');
        history.replaceState(null, '', u.toString());
      } catch {}
    }

    const shouldShow = hasParam || hasCookie || inCap;
    if (!shouldShow) return;
    if (document.getElementById('fr-mobile-fab')) return;

    // FAB
    const fab = document.createElement('button');
    fab.id = 'fr-mobile-fab';
    fab.type = 'button';
    fab.setAttribute('aria-label','Switch server');
    fab.style.cssText = [
      'position:fixed','right:14px','bottom:14px','z-index:2147483647',
      'width:56px','height:56px','border-radius:28px','border:0','cursor:pointer',
      'background:#2196F3','color:#fff','box-shadow:0 10px 26px rgba(33,150,243,.35)',
      'display:flex','align-items:center','justify-content:center'
    ].join(';');
    fab.innerHTML = '<svg viewBox="0 0 24 24" width="26" height="26" fill="currentColor" aria-hidden="true"><path d="M4 6h16v2H4V6zm0 5h10v2H4v-2zm0 5h16v2H4v-2z"/></svg>';

    fab.addEventListener('click', () => {
      // Bounce back to the app’s home to pick another instance
      location.href = 'capacitor://localhost/index.html#switch';
    });

    // Add to DOM
    const append = () => document.body ? document.body.appendChild(fab) : setTimeout(append, 50);
    append();

    // Optional: triple-tap header to switch
    let taps = 0, last = 0;
    const header = document.querySelector('.header, header, .navbar, .app-header') || document.body;
    header.addEventListener('touchend', () => {
      const now = Date.now();
      taps = (now - last < 400) ? taps + 1 : 1;
      last = now;
      if (taps >= 3) { taps = 0; location.href = 'capacitor://localhost/index.html#switch'; }
    });
  } catch {}
})();