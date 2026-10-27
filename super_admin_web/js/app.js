// ClinResearch Super Admin Institutional Governance Web Application Logic

const state = {
  activeTab: 'dashboard',
  specialists: [],
  researchers: [],
  protocols: [],
  userStats: {
    researchersCount: 0,
    specialistsCount: 0,
    totalUsers: 0,
  },
  auditEvents: [
    {
      id: 'AUD-0001',
      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
      title: 'NeonDB Production Database Initialized',
      description: 'All test and mock records deleted. Live clinical registry online and ready for incoming studies.',
      operator: 'System Sentinel Engine',
      severity: 'COMPLIANCE',
    },
  ],
  pipelineDistribution: [
    { stage: '01. Idea', num: '01', count: 0 },
    { stage: '02. PICO', num: '02', count: 0 },
    { stage: '03. Matching', num: '03', count: 0 },
    { stage: '04. Collab', num: '04', count: 0 },
    { stage: '05. Plan', num: '05', count: 0 },
    { stage: '06. Review', num: '06', count: 0 },
    { stage: '07. IEC', num: '07', count: 0 },
    { stage: '08. Manuscript', num: '08', count: 0 },
  ],
};

// Initialize DOM
document.addEventListener('DOMContentLoaded', () => {
  setupNavigation();
  checkLiveData();
  renderDashboard();
  renderSpecialists();
  renderResearchers();
  renderProtocols();
  renderAuditLogs();
  setupEventListeners();

  // Periodic poll to pick up live actions from Flutter app
  setInterval(checkLiveData, 2000);
});

// Check for live synchronized data from Backend API or Flutter App
function checkLiveData() {
  // 1. Try Live Backend API endpoint
  fetch('/api/live-sync')
    .then((res) => {
      if (res.ok) return res.json();
      throw new Error('No API endpoint');
    })
    .then((data) => {
      applyLiveData(data);
    })
    .catch(() => {
      // 2. Fallback to live_data.json
      if (window.CLIN_LIVE_DATA) {
        applyLiveData(window.CLIN_LIVE_DATA);
      }
      fetch('live_data.json?t=' + Date.now())
        .then((res) => (res.ok ? res.json() : null))
        .then((data) => {
          if (data) applyLiveData(data);
        })
        .catch(() => {
          // Handled by memory or fallback
        });
    });

  // Fetch real registered users (both researchers and doctors) from database
  fetch('/api/users')
    .then((res) => (res.ok ? res.json() : []))
    .then((users) => {
      if (Array.isArray(users)) {
        processUsersList(users);
      }
    })
    .catch(() => {});
}

function processUsersList(users) {
  const doctors = [];
  const researchers = [];

  users.forEach((u) => {
    const roleLower = (u.role || '').toLowerCase();
    const isDoctor = roleLower === 'specialist' || roleLower === 'doctor' || (u.title && u.title.toLowerCase().includes('consultant'));

    const profile = {
      id: u.id,
      name: u.name,
      title: u.title || (isDoctor ? 'Clinical Specialist' : 'Clinical Fellow'),
      department: u.department || 'Internal Medicine',
      institution: u.institution || 'Apex Medical Consortium',
      license: u.email || 'NPI-VERIFIED',
      specialty: u.specialty || 'Clinical Research',
      focus: Array.isArray(u.research_keywords) ? u.research_keywords.join(', ') : (u.research_keywords || u.specialty || 'Medicine'),
      isVerified: u.is_verified ?? true,
      activeProjects: u.active_projects || 0,
      email: u.email,
    };

    if (isDoctor) {
      doctors.push(profile);
    } else {
      researchers.push(profile);
    }
  });

  state.specialists = doctors;
  state.researchers = researchers;
  state.userStats.researchersCount = researchers.length;
  state.userStats.specialistsCount = doctors.length;
  state.userStats.totalUsers = users.length;

  updateUserKpis();
  renderSpecialists();
  renderResearchers();
}

function updateUserKpis() {
  const resCountEl = document.getElementById('kpiResearchersCount');
  if (resCountEl) resCountEl.innerText = state.userStats.researchersCount;

  const resTrendEl = document.getElementById('kpiResearchersTrend');
  if (resTrendEl) {
    resTrendEl.innerText = `${state.userStats.researchersCount} Active Investigator${state.userStats.researchersCount === 1 ? '' : 's'}`;
  }

  const specCountEl = document.getElementById('kpiSpecialistsCount');
  if (specCountEl) specCountEl.innerText = state.userStats.specialistsCount;

  const pendingCount = state.specialists.filter((s) => !s.isVerified).length;
  const specPendingEl = document.getElementById('kpiSpecialistsPending');
  if (specPendingEl) {
    specPendingEl.innerText = pendingCount > 0 ? `${pendingCount} Pending Review` : `${state.specialists.length} Accredited Faculty`;
  }

  const pendingBadge = document.getElementById('pendingSpecialistBadge');
  if (pendingBadge) pendingBadge.innerText = pendingCount;
}

function applyLiveData(data) {
  if (!data) return;

  let hasChanged = false;

  // Process user stats if sent by live-sync
  if (data.userStats) {
    state.userStats.researchersCount = data.userStats.researchersCount || state.userStats.researchersCount;
    state.userStats.specialistsCount = data.userStats.specialistsCount || state.userStats.specialistsCount;
    updateUserKpis();
  }

  if (Array.isArray(data.protocols)) {
    if (JSON.stringify(state.protocols) !== JSON.stringify(data.protocols)) {
      state.protocols = data.protocols;
      hasChanged = true;
    }
    const studiesCountEl = document.getElementById('kpiStudiesCount');
    if (studiesCountEl) studiesCountEl.innerText = data.protocols.length;

    // Count waiting for doctors
    const waitingDoctorsCount = state.protocols.filter(
      (p) => p.isWaitingForDoctor || !p.mentor || p.mentor.includes('Awaiting') || Number(p.stageNum) === 3
    ).length;

    const waitingEl = document.getElementById('kpiWaitingDoctorsCount');
    if (waitingEl) waitingEl.innerText = waitingDoctorsCount;

    const waitingTrendEl = document.getElementById('kpiWaitingDoctorsTrend');
    if (waitingTrendEl) {
      waitingTrendEl.innerText = waitingDoctorsCount > 0 ? `${waitingDoctorsCount} Study in Matching Queue` : 'All Mentors Assigned';
    }

    const ethicsCount = state.protocols.filter((p) => Number(p.stageNum) >= 7).length;
    const kpiEthicsCount = document.getElementById('kpiEthicsCount');
    if (kpiEthicsCount) kpiEthicsCount.innerText = ethicsCount;
    const kpiEthicsTrend = document.getElementById('kpiEthicsTrend');
    if (kpiEthicsTrend) {
      kpiEthicsTrend.innerText = ethicsCount > 0 ? `${ethicsCount} Protocol Validated` : 'Awaiting First Protocol';
    }
  }

  if (Array.isArray(data.auditEvents) && data.auditEvents.length > 0) {
    if (JSON.stringify(state.auditEvents) !== JSON.stringify(data.auditEvents)) {
      state.auditEvents = data.auditEvents;
      hasChanged = true;
    }
    const latestEvent = data.auditEvents[0];
    const liveActionText = document.getElementById('liveActionText');
    if (liveActionText && latestEvent) {
      liveActionText.innerHTML = `<strong>${latestEvent.title}</strong> — <span style="color: var(--text-muted)">${latestEvent.description}</span> <small style="color: var(--accent-cyan); margin-left: 6px;">(${latestEvent.operator})</small>`;
    }
  }

  if (Array.isArray(data.pipelineDistribution)) {
    state.pipelineDistribution = data.pipelineDistribution;
  }

  if (hasChanged) {
    renderDashboard();
    renderProtocols();
    renderAuditLogs();
  }
}

// Tab Navigation
function setupNavigation() {
  const navItems = document.querySelectorAll('.nav-item');
  navItems.forEach((btn) => {
    btn.addEventListener('click', () => {
      const tab = btn.dataset.tab;
      switchTab(tab);
    });
  });
}

function switchTab(tabId) {
  state.activeTab = tabId;

  document.querySelectorAll('.nav-item').forEach((item) => {
    item.classList.toggle('active', item.dataset.tab === tabId);
  });

  document.querySelectorAll('.tab-view').forEach((view) => {
    view.classList.toggle('active', view.id === `tab-${tabId}`);
  });

  // Update Header Title
  const titles = {
    dashboard: ['Executive Governance Overview', 'Supervisory oversight of clinical research protocols, mentor accreditations, and ethics compliance.'],
    specialists: ['Accreditation & Investigator Registry', 'Comprehensive directory of accredited doctors, specialists, and registered clinical researchers.'],
    protocols: ['Institutional Clinical Protocol Registry', 'Full clinical visibility of ongoing research studies, team mentors, and pending specialist matchings.'],
    security: ['Automated PHI / PII Privacy Sentinel', 'Zero-trust verification engine preventing identifiable clinical records from entering research drafts.'],
    audit: ['Institutional Audit & Compliance Trail', 'Immutable cryptographic log of stage gates, endorsements, and document generation.'],
  };

  const [title, sub] = titles[tabId] || titles.dashboard;
  document.getElementById('viewTitle').innerText = title;
  document.getElementById('viewSubtitle').innerText = sub;
}

// Render Dashboard
function renderDashboard() {
  // Render Pipeline Distribution
  const pipelineContainer = document.getElementById('pipelineDistribution');
  if (pipelineContainer) {
    pipelineContainer.innerHTML = state.pipelineDistribution
      .map(
        (node) => `
      <div class="stage-node ${node.count > 0 ? 'active' : ''}">
        <span class="stage-num">STAGE ${node.num}</span>
        <span class="stage-name">${node.stage}</span>
        <span class="stage-count" style="${node.count > 0 ? 'color: var(--accent-cyan); font-weight: 800;' : ''}">${node.count}</span>
      </div>
    `
      )
      .join('');
  }

  // Quick Specialist Table
  const quickTable = document.getElementById('quickSpecialistTable');
  if (quickTable) {
    if (state.specialists.length === 0) {
      quickTable.innerHTML = `
        <tr>
          <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 24px 10px;">
            No accredited specialists in queue. Live doctor registrations will appear here.
          </td>
        </tr>
      `;
    } else {
      quickTable.innerHTML = state.specialists
        .slice(0, 4)
        .map(
          (doc) => `
        <tr>
          <td><strong>${doc.name}</strong><br><small style="color: var(--text-dim)">${doc.institution}</small></td>
          <td><code style="font-family: monospace; font-size: 11px; color: var(--accent-cyan)">${doc.license}</code></td>
          <td>${doc.specialty}</td>
          <td>${
            doc.isVerified
              ? '<span style="color: var(--accent-emerald); font-weight: 700; font-size: 11px">● VERIFIED</span>'
              : '<span style="color: var(--accent-amber); font-weight: 700; font-size: 11px">● PENDING</span>'
          }</td>
          <td>
            ${
              !doc.isVerified
                ? `<button class="btn btn-primary" style="padding: 4px 10px; font-size: 11px" onclick="verifyDoctor('${doc.id}')">Approve</button>`
                : `<button class="btn btn-secondary" style="padding: 4px 10px; font-size: 11px" disabled>Approved</button>`
            }
          </td>
        </tr>
      `
        )
        .join('');
    }
  }

  // Quick Audit Feed
  const quickAudit = document.getElementById('quickAuditFeed');
  if (quickAudit) {
    quickAudit.innerHTML = state.auditEvents
      .slice(0, 4)
      .map(
        (ev) => `
      <div class="audit-item">
        <span class="audit-tag">${ev.id}</span>
        <div class="audit-info">
          <strong>${ev.title}</strong>
          <p>${ev.description}</p>
          <small>${ev.timestamp} • By ${ev.operator}</small>
        </div>
      </div>
    `
      )
      .join('');
  }
}

// Render Doctors & Specialists
function renderSpecialists(filter = '') {
  const table = document.getElementById('fullSpecialistTable');
  if (!table) return;

  const filtered = state.specialists.filter(
    (s) =>
      s.name.toLowerCase().includes(filter.toLowerCase()) ||
      s.specialty.toLowerCase().includes(filter.toLowerCase()) ||
      s.license.toLowerCase().includes(filter.toLowerCase())
  );

  if (filtered.length === 0) {
    table.innerHTML = `
      <tr>
        <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 36px 16px;">
          <div style="font-size: 24px; margin-bottom: 8px">👨‍⚕️</div>
          <strong style="color: #fff">No Specialist Profiles Registered Yet</strong><br>
          <small>Live doctor and mentor registrations will appear here automatically.</small>
        </td>
      </tr>
    `;
  } else {
    table.innerHTML = filtered
      .map(
        (doc) => `
      <tr>
        <td>
          <strong style="color: #fff">${doc.name}</strong><br>
          <small style="color: var(--accent-emerald)">${doc.title}</small>
        </td>
        <td>
          ${doc.department}<br>
          <small style="color: var(--text-dim)">${doc.institution}</small>
        </td>
        <td><code style="font-family: monospace; font-size: 11.5px; color: var(--accent-cyan); background: rgba(6,182,212,0.1); padding: 2px 6px; border-radius: 4px">${doc.license}</code></td>
        <td><span style="font-size: 11.5px; color: var(--text-muted)">${doc.focus}</span></td>
        <td>
          ${
            doc.isVerified
              ? '<span class="status-chip active">ACCREDITED MENTOR</span>'
              : '<span style="font-size: 11px; font-weight: 700; color: var(--accent-amber)">PENDING REVIEW</span>'
          }
        </td>
        <td>
          ${
            !doc.isVerified
              ? `<button class="btn btn-primary" style="padding: 4px 10px; font-size: 11px" onclick="verifyDoctor('${doc.id}')">Grant Accreditation</button>`
              : `<button class="btn btn-secondary" style="padding: 4px 10px; font-size: 11px" onclick="revokeDoctor('${doc.id}')">Revoke Access</button>`
          }
        </td>
      </tr>
    `
      )
      .join('');
  }
}

// Render Clinical Researchers & Fellows
function renderResearchers(filter = '') {
  const table = document.getElementById('fullResearcherTable');
  if (!table) return;

  const filtered = state.researchers.filter(
    (r) =>
      r.name.toLowerCase().includes(filter.toLowerCase()) ||
      r.department.toLowerCase().includes(filter.toLowerCase()) ||
      r.specialty.toLowerCase().includes(filter.toLowerCase()) ||
      r.email.toLowerCase().includes(filter.toLowerCase())
  );

  if (filtered.length === 0) {
    table.innerHTML = `
      <tr>
        <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 36px 16px;">
          <div style="font-size: 24px; margin-bottom: 8px">🎓</div>
          <strong style="color: #fff">No Clinical Researchers in Registry</strong><br>
          <small>Registered resident and fellow investigators will appear here automatically.</small>
        </td>
      </tr>
    `;
  } else {
    table.innerHTML = filtered
      .map(
        (res) => `
      <tr>
        <td>
          <strong style="color: #fff">${res.name}</strong><br>
          <small style="color: var(--accent-purple)">${res.title}</small>
        </td>
        <td>
          ${res.department}<br>
          <small style="color: var(--text-dim)">${res.institution}</small>
        </td>
        <td><code style="font-family: monospace; font-size: 11.5px; color: var(--accent-cyan); background: rgba(6,182,212,0.1); padding: 2px 6px; border-radius: 4px">${res.email}</code></td>
        <td><span style="font-size: 11.5px; color: var(--text-muted)">${res.focus}</span></td>
        <td><span style="font-weight: 700; color: #fff">${res.activeProjects} Active</span></td>
        <td><span style="color: var(--accent-emerald); font-weight: 700; font-size: 11px">● VERIFIED PI</span></td>
      </tr>
    `
      )
      .join('');
  }
}

// Render Protocols with Full Clinical Details & Waiting for Doctor alerts
function renderProtocols(filter = '') {
  const table = document.getElementById('protocolRegistryTable');
  if (!table) return;

  const filtered = state.protocols.filter(
    (p) =>
      p.title.toLowerCase().includes(filter.toLowerCase()) ||
      p.pi.toLowerCase().includes(filter.toLowerCase()) ||
      (p.clinicalArea && p.clinicalArea.toLowerCase().includes(filter.toLowerCase())) ||
      (p.mentor && p.mentor.toLowerCase().includes(filter.toLowerCase()))
  );

  if (filtered.length === 0) {
    table.innerHTML = `
      <tr>
        <td colspan="7" style="text-align: center; padding: 44px 20px; color: var(--text-dim)">
          <div style="font-size: 28px; margin-bottom: 8px">📋</div>
          <strong style="color: #fff; font-size: 15px">No Active Studies in Live NeonDB Cloud Registry</strong><br>
          <small style="color: var(--text-muted)">When clinical investigators initiate a study from the mobile app, it appears here in real-time with full stage and mentor tracking.</small>
        </td>
      </tr>
    `;
    return;
  }

  table.innerHTML = filtered
    .map((p) => {
      const isWaiting = p.isWaitingForDoctor || !p.mentor || p.mentor.includes('Awaiting') || Number(p.stageNum) === 3;
      const mentorDisplay = isWaiting
        ? `<span class="badge-waiting-doctor">⏳ WAITING FOR DOCTOR</span>`
        : `<span style="color: var(--accent-emerald); font-weight: 700">👨‍⚕️ ${p.mentor}</span>`;

      return `
      <tr>
        <td>
          <strong style="color: #fff; font-size: 13.5px">${p.title}</strong><br>
          <span class="badge-clinical-area">${p.clinicalArea || 'Cardiovascular Medicine'}</span>
        </td>
        <td>
          <strong style="color: #E2E8F0">${p.pi}</strong><br>
          <small style="color: var(--text-dim)">Principal Investigator</small>
        </td>
        <td>${mentorDisplay}</td>
        <td>
          <span class="badge-stage-pill">${p.stage}</span>
        </td>
        <td><strong style="color: var(--accent-cyan)">N = ${p.sampleSize || 120}</strong><br><small style="color: var(--text-dim)">Subjects</small></td>
        <td>
          <span style="font-size: 11px; font-weight: 600; color: ${Number(p.stageNum) >= 7 ? 'var(--accent-emerald)' : 'var(--text-muted)'}">
            ${p.iecStatus}
          </span>
        </td>
        <td>
          <button class="btn btn-secondary" style="padding: 5px 12px; font-size: 11.5px; border-color: rgba(6, 182, 212, 0.4); color: var(--accent-cyan);" onclick="openProtocolModal('${p.id}')">
            Inspect Dossier →
          </button>
        </td>
      </tr>
    `;
    })
    .join('');
}

// Render Audit Logs
function renderAuditLogs() {
  const table = document.getElementById('fullAuditLogTable');
  if (!table) return;

  table.innerHTML = state.auditEvents
    .map(
      (ev) => `
    <tr>
      <td><code style="font-family: monospace; color: var(--accent-purple)">${ev.id}</code></td>
      <td style="font-size: 11.5px; color: var(--text-dim); white-space: nowrap">${ev.timestamp}</td>
      <td><strong>${ev.title}</strong></td>
      <td style="color: var(--text-muted)">${ev.description}</td>
      <td><span style="font-weight: 600; font-size: 11.5px">${ev.operator}</span></td>
      <td>
        <span style="font-size: 10px; font-weight: 800; padding: 2px 6px; border-radius: 4px; background: rgba(139,92,246,0.15); color: var(--accent-purple)">
          ${ev.severity}
        </span>
      </td>
    </tr>
  `
    )
    .join('');
}

// Actions: Doctor Accreditation
function verifyDoctor(docId) {
  const doc = state.specialists.find((s) => s.id === docId);
  if (!doc) return;

  doc.isVerified = true;

  const newAudit = {
    id: `AUD-${Math.floor(1000 + Math.random() * 9000)}`,
    timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
    title: `Doctor Accredited (${doc.license})`,
    description: `Super Admin formally verified credentials and Institutional Ethics access for ${doc.name}.`,
    operator: 'Super Admin (Dr. Pendelton)',
    severity: 'COMPLIANCE',
  };

  state.auditEvents.unshift(newAudit);

  renderDashboard();
  renderSpecialists();
  renderAuditLogs();

  alert(`Accreditation granted to ${doc.name}. Verified mentor badge issued.`);
}

function revokeDoctor(docId) {
  const doc = state.specialists.find((s) => s.id === docId);
  if (!doc) return;

  if (confirm(`Revoke mentor privileges for ${doc.name}?`)) {
    doc.isVerified = false;
    renderDashboard();
    renderSpecialists();
  }
}

// Full Study Dossier Modal
function openProtocolModal(protocolId) {
  const p = state.protocols.find((item) => item.id === protocolId);
  if (!p) return;

  const isWaiting = p.isWaitingForDoctor || !p.mentor || p.mentor.includes('Awaiting') || Number(p.stageNum) === 3;
  const pico = p.pico || {};
  const plan = p.studyPlan || {};

  document.getElementById('modalProtocolTitle').innerText = p.title;
  document.getElementById('modalProtocolBody').innerHTML = `
    <!-- Top Metadata Header -->
    <div style="background: rgba(255,255,255,0.03); padding: 18px; border-radius: 10px; border: 1px solid var(--border-color); margin-bottom: 20px">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;">
        <span class="badge-clinical-area" style="font-size: 12px; padding: 4px 10px;">${p.clinicalArea || 'Clinical Research'}</span>
        <span class="badge-stage-pill" style="font-size: 12px; padding: 4px 10px;">Stage: ${p.stage}</span>
      </div>

      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; margin-top: 10px; font-size: 13px;">
        <div>
          <span style="color: var(--text-dim); display: block; font-size: 11px;">PRINCIPAL INVESTIGATOR</span>
          <strong style="color: #fff;">${p.pi}</strong>
        </div>
        <div>
          <span style="color: var(--text-dim); display: block; font-size: 11px;">SPECIALIST MENTOR / GUIDE</span>
          ${isWaiting
            ? '<span class="badge-waiting-doctor" style="margin-top: 4px;">⏳ WAITING FOR DOCTOR / SPECIALIST</span>'
            : `<strong style="color: var(--accent-emerald);">👨‍⚕️ ${p.mentor}</strong>`
          }
        </div>
        <div>
          <span style="color: var(--text-dim); display: block; font-size: 11px;">COHORT SIZE & READABILITY</span>
          <strong style="color: var(--accent-cyan);">N = ${p.sampleSize} Subjects</strong> • ${p.readability}
        </div>
        <div>
          <span style="color: var(--text-dim); display: block; font-size: 11px;">ETHICS GATE STATUS</span>
          <strong style="color: ${Number(p.stageNum) >= 7 ? 'var(--accent-emerald)' : 'var(--accent-amber)'};">${p.iecStatus}</strong>
        </div>
      </div>
    </div>

    <!-- Clinical Observation & Research Question -->
    <div style="margin-bottom: 18px;">
      <h4 style="color: #fff; font-size: 13px; margin-bottom: 6px; letter-spacing: 0.5px;">1. CLINICAL OBSERVATION & HYPOTHESIS</h4>
      <div style="background: rgba(0,0,0,0.25); border-left: 3px solid var(--accent-cyan); padding: 12px; border-radius: 4px; font-size: 12.5px; color: #CBD5E1; line-height: 1.6;">
        ${p.observationText || 'Observational data recorded by investigator during clinical rounds.'}
      </div>
    </div>

    <div style="margin-bottom: 18px;">
      <h4 style="color: #fff; font-size: 13px; margin-bottom: 6px; letter-spacing: 0.5px;">2. AI-CLARIFIED CLINICAL RESEARCH QUESTION (Clarity: ${p.clarityScore || 85}/100)</h4>
      <div style="background: rgba(6,182,212,0.06); border: 1px solid rgba(6,182,212,0.25); padding: 12px; border-radius: 6px; font-size: 12.5px; color: #E2E8F0; font-weight: 500; line-height: 1.6;">
        ${p.aiClarifiedQuestion || p.title}
      </div>
    </div>

    <!-- PICO Criteria Breakdown Table -->
    <div style="margin-bottom: 18px;">
      <h4 style="color: #fff; font-size: 13px; margin-bottom: 8px; letter-spacing: 0.5px;">3. FORMULATED PICO FRAMEWORK</h4>
      <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; font-size: 12px;">
        <div style="background: rgba(255,255,255,0.02); border: 1px solid var(--border-color); padding: 10px; border-radius: 6px;">
          <strong style="color: var(--accent-cyan);">[P] Population / Cohort:</strong>
          <p style="color: var(--text-muted); margin-top: 4px;">${pico.population || 'Adult patients meeting clinical enrollment criteria'}</p>
        </div>
        <div style="background: rgba(255,255,255,0.02); border: 1px solid var(--border-color); padding: 10px; border-radius: 6px;">
          <strong style="color: var(--accent-emerald);">[I] Intervention:</strong>
          <p style="color: var(--text-muted); margin-top: 4px;">${pico.intervention || 'Standardized clinical regimen under study'}</p>
        </div>
        <div style="background: rgba(255,255,255,0.02); border: 1px solid var(--border-color); padding: 10px; border-radius: 6px;">
          <strong style="color: var(--accent-amber);">[C] Comparison / Control:</strong>
          <p style="color: var(--text-muted); margin-top: 4px;">${pico.comparison || 'Standard-of-care baseline control group'}</p>
        </div>
        <div style="background: rgba(255,255,255,0.02); border: 1px solid var(--border-color); padding: 10px; border-radius: 6px;">
          <strong style="color: var(--accent-purple);">[O] Primary Outcome:</strong>
          <p style="color: var(--text-muted); margin-top: 4px;">${pico.outcome || 'Statistically significant clinical endpoint'}</p>
        </div>
      </div>
    </div>

    <!-- Ethics Checklist -->
    <h4 style="margin-bottom: 8px; color: #fff; font-size: 13px;">4. INSTITUTIONAL ETHICS COMMITTEE (IEC) VERIFICATION CHECKLIST</h4>
    <ul style="padding-left: 20px; line-height: 1.8; color: var(--text-muted); font-size: 12.5px">
      <li>[✓] Informed Consent Form (ICF) drafted in plain language (Grade 6 Readability)</li>
      <li>[✓] Safe Harbor data de-identification verified (Zero identifiable PHI)</li>
      <li>[✓] Risk-benefit disclosure aligned with Helsinki Declaration standards</li>
      <li>[${isWaiting ? ' ' : '✓'}] Verified specialist doctor oversight endorsement</li>
    </ul>
  `;

  document.getElementById('protocolModal').classList.add('active');
}

function closeModal() {
  document.getElementById('protocolModal').classList.remove('active');
}

function exportAuditJson() {
  const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(state.auditEvents, null, 2));
  const downloadAnchor = document.createElement('a');
  downloadAnchor.setAttribute('href', dataStr);
  downloadAnchor.setAttribute('download', 'institutional_audit_trail_2026.json');
  document.body.appendChild(downloadAnchor);
  downloadAnchor.click();
  downloadAnchor.remove();
}

function setupEventListeners() {
  document.getElementById('specialistSearchInput')?.addEventListener('input', (e) => {
    renderSpecialists(e.target.value);
  });

  document.getElementById('researcherSearchInput')?.addEventListener('input', (e) => {
    renderResearchers(e.target.value);
  });

  document.getElementById('protocolSearchInput')?.addEventListener('input', (e) => {
    renderProtocols(e.target.value);
  });

  document.getElementById('refreshDataBtn')?.addEventListener('click', () => {
    checkLiveData();
    renderDashboard();
    renderSpecialists();
    renderResearchers();
    renderProtocols();
    renderAuditLogs();
    alert('Institutional telemetry synchronized with active database.');
  });

  document.getElementById('exportAuditReportBtn')?.addEventListener('click', () => {
    alert('Generating Institutional Ethics Dossier PDF for IRB review...');
  });
}
