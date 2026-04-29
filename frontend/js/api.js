// js/api.js
const BASE = '/api';

async function api(endpoint, options = {}) {
  const token = localStorage.getItem('maritime_token');
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;
  const res  = await fetch(BASE + endpoint, { ...options, headers: { ...headers, ...options.headers } });
  const data = await res.json();
  if (!res.ok) throw { status: res.status, message: data.message || 'Request failed', data };
  return data;
}

async function apiUpload(endpoint, formData) {
  const token = localStorage.getItem('maritime_token');
  const headers = {};
  if (token) headers['Authorization'] = `Bearer ${token}`;
  const res  = await fetch(BASE + endpoint, { method: 'POST', headers, body: formData });
  const data = await res.json();
  if (!res.ok) throw { status: res.status, message: data.message || 'Upload failed' };
  return data;
}

function showToast(msg, type = 'info') {
  let t = document.getElementById('toast');
  if (!t) { t = document.createElement('div'); t.id = 'toast'; document.body.appendChild(t); }
  t.className = `toast-${type}`; t.textContent = msg; t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), 3500);
}

function showMsg(elId, msg, type) {
  const el = document.getElementById(elId);
  if (!el) return;
  el.className = `form-msg ${type}`; el.textContent = msg; el.classList.remove('hidden');
}

function fmt(n) { return new Intl.NumberFormat('en-IN').format(n||0); }
function fmtDate(d) { if (!d) return '—'; return new Date(d).toLocaleDateString('en-IN',{day:'numeric',month:'short',year:'numeric'}); }
function fmtUSD(n) { return '$' + fmt(n); }

function statusBadge(s) {
  const m = {'Applied':'badge-info','Under Review':'badge-warning','Selected':'badge-success','Rejected':'badge-danger'};
  return `<span class="badge ${m[s]||'badge-teal'}">${s}</span>`;
}
function verifyBadge(s) {
  const m = {'Verified':'badge-success','Pending':'badge-warning','Rejected':'badge-danger'};
  return `<span class="badge ${m[s]||'badge-info'}">${s}</span>`;
}
function deadlineBadge(s) {
  if (!s) return '';
  const cls = s==='Open Now'?'deadline-open':s==='Upcoming'?'deadline-upcoming':'deadline-closed';
  const icon= s==='Open Now'?'🟢':s==='Upcoming'?'🟡':'🔴';
  return `<span class="${cls}">${icon} ${s}</span>`;
}

function logout() { localStorage.clear(); location.href = 'index.html'; }

function setAuthNav(navId) {
  const u = localStorage.getItem('maritime_user');
  const el = document.getElementById(navId);
  if (!el) return;
  if (u) {
    const s = JSON.parse(u);
    el.innerHTML = `<a href="dashboard.html">Dashboard</a>
      <button class="btn btn-outline btn-sm" onclick="logout()">Logout</button>`;
  } else {
    el.innerHTML = `<a href="index.html" class="btn btn-primary btn-sm">Login / Register</a>`;
  }
}
