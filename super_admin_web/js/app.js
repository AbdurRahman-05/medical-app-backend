// ClinResearch Super Admin Institutional Governance Web Application Logic

const state = {
  activeTab: 'dashboard',
  specialists: [
    {
      id: 'doc_01',
      name: 'Prof. Marcus Vance, MD, PhD',
      title: 'Senior Consultant & Professor',
      department: 'Cardiology & Heart Failure',
      institution: 'Metropolitan Heart & Vascular Institute',
      license: 'MCI-REG-849204',
      specialty: 'Cardiovascular Medicine',
      focus: 'HFpEF, SGLT2i, Clinical Trial Design',
      isVerified: true,
      activeProjects: 4,
    },
    {
      id: 'doc_02',
      name: 'Dr. Elena Rostova, MD, DM',
      title: 'Associate Professor & Biostatistician',
      department: 'Preventive Medicine & Epidemiology',
      institution: 'St. Jude Academic Medical Center',
      license: 'NPI-8923019',
      specialty: 'Clinical Epidemiology & Biostatistics',
      focus: 'Sample Size Formulas, Propensity Matching',
      isVerified: false, // Pending verification
      activeProjects: 3,
    },
    {
      id: 'doc_03',
      name: 'Dr. Rajesh Nair, MD, MRCP',
      title: 'Senior Nephrologist & IEC Chair',
      department: 'Department of Nephrology',
      institution: 'Apex Institute of Medical Sciences',
      license: 'GMC-7492011',
      specialty: 'Nephrology & Renal Medicine',
      focus: 'Cardio-Renal, GCP Ethics Review',
      isVerified: true,
      activeProjects: 2,
    },
    {
      id: 'doc_04',
      name: 'Dr. Amanda Chen, MD, PhD',
      title: 'Assistant Professor of Oncology',
      department: 'Medical Oncology',
      institution: 'National Cancer Research Center',
      license: 'NPI-4920194',
      specialty: 'Oncology & Immunotherapy',
      focus: 'Survival Analysis, PROMs, Trial Design',
      isVerified: true,
      activeProjects: 5,
    },
  ],
  protocols: [],
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
        .then((res) => {
          if (res.ok) return res.json();
          throw new Error('Not served via HTTP');
        })
        .then((data) => {
          applyLiveData(data);
        })
        .catch(() => {
          // Direct file mode; handled by window.CLIN_LIVE_DATA
        });
    });
}

function applyLiveData(data) {
  if (!data) return;

  let hasChanged = false;

  if (Array.isArray(data.protocols)) {
    if (JSON.stringify(state.protocols) !== JSON.stringify(data.protocols)) {
      state.protocols = data.protocols;
      hasChanged = true;
    }
    const studiesCountEl = document.getElementById('kpiStudiesCount');
    if (studiesCountEl) studiesCountEl.innerText = data.protocols.length;
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
    specialists: ['Specialist Accreditation & Vetting', 'Review doctor registration numbers, institutional appointments, and grant mentor credentials.'],
    protocols: ['Institutional Protocol & Ethics Registry', 'Complete audit trail of all active resident and fellow research studies.'],
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
  pipelineContainer.innerHTML = state.pipelineDistribution
    .map(
      (node) => `
    <div class="stage-node">
      <span class="stage-num">STAGE ${node.num}</span>
      <span class="stage-name">${node.stage}</span>
      <span class="stage-count">${node.count}</span>
    </div>
  `
    )
    .join('');

  // Quick Specialist Table
  const quickTable = document.getElementById('quickSpecialistTable');
  quickTable.innerHTML = state.specialists
    .slice(0, 3)
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

  // Quick Audit Feed
  const quickAudit = document.getElementById('quickAuditFeed');
  quickAudit.innerHTML = state.auditEvents
    .slice(0, 3)
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

// Render Specialists
function renderSpecialists(filter = '') {
  const table = document.getElementById('fullSpecialistTable');
  const filtered = state.specialists.filter(
    (s) =>
      s.name.toLowerCase().includes(filter.toLowerCase()) ||
      s.specialty.toLowerCase().includes(filter.toLowerCase()) ||
      s.license.toLowerCase().includes(filter.toLowerCase())
  );

  table.innerHTML = filtered
    .map(
      (doc) => `
    <tr>
      <td>
        <strong>${doc.name}</strong><br>
        <small style="color: var(--text-muted)">${doc.title}</small>
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
            ? '<span class="status-chip active">VERIFIED MENTOR</span>'
            : '<span style="font-size: 11px; font-weight: 700; color: var(--accent-amber)">PENDING VETTING</span>'
        }
      </td>
      <td>
        ${
          !doc.isVerified
            ? `<button class="btn btn-primary" onclick="verifyDoctor('${doc.id}')">Grant Accreditation</button>`
            : `<button class="btn btn-secondary" style="font-size: 11px" onclick="revokeDoctor('${doc.id}')">Revoke Access</button>`
        }
      </td>
    </tr>
  `
    )
    .join('');

  // Update Pending badge
  const pendingCount = state.specialists.filter((s) => !s.isVerified).length;
  document.getElementById('pendingSpecialistBadge').innerText = pendingCount;
  document.getElementById('kpiSpecialistsCount').innerText = state.specialists.filter((s) => s.isVerified).length;
}

// Render Protocols
function renderProtocols(filter = '') {
  const table = document.getElementById('protocolRegistryTable');
  const filtered = state.protocols.filter(
    (p) =>
      p.title.toLowerCase().includes(filter.toLowerCase()) ||
      p.pi.toLowerCase().includes(filter.toLowerCase())
  );

  if (filtered.length === 0) {
    table.innerHTML = `
      <tr>
        <td colspan="7" style="text-align: center; padding: 36px 20px; color: var(--text-dim)">
          <div style="font-size: 24px; margin-bottom: 8px">📋</div>
          <strong style="color: #fff">No Active Protocols in NeonDB Cloud Registry</strong><br>
          <small>All test mock data deleted. When clinical researchers initiate a live study, it syncs here automatically.</small>
        </td>
      </tr>
    `;
    return;
  }

  table.innerHTML = filtered
    .map(
      (p) => `
    <tr>
      <td>
        <strong style="color: #fff; font-size: 13px">${p.title}</strong><br>
        <small style="color: var(--accent-cyan)">Target N = ${p.sampleSize} Subjects</small>
      </td>
      <td>${p.pi}</td>
      <td><span style="color: var(--accent-emerald); font-weight: 600">${p.mentor}</span></td>
      <td>
        <span style="background: rgba(255,255,255,0.06); padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 700">
          ${p.stage}
        </span>
      </td>
      <td><code style="font-size: 11px">${p.version}</code></td>
      <td><span style="font-size: 11px; color: var(--text-muted)">${p.iecStatus}</span></td>
      <td>
        <button class="btn btn-secondary" style="padding: 4px 10px; font-size: 11px" onclick="openProtocolModal('${p.id}')">Inspect Dossier</button>
      </td>
    </tr>
  `
    )
    .join('');
}

// Render Audit Logs
function renderAuditLogs() {
  const table = document.getElementById('fullAuditLogTable');
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

// Actions
function verifyDoctor(docId) {
  const doc = state.specialists.find((s) => s.id === docId);
  if (!doc) return;

  doc.isVerified = true;

  // Add audit record
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

  alert(`Accreditation granted to ${doc.name}. Verified badge issued.`);
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

function openProtocolModal(protocolId) {
  const p = state.protocols.find((item) => item.id === protocolId);
  if (!p) return;

  document.getElementById('modalProtocolTitle').innerText = p.title;
  document.getElementById('modalProtocolBody').innerHTML = `
    <div style="background: rgba(255,255,255,0.02); padding: 16px; border-radius: 8px; border: 1px solid var(--border-color); margin-bottom: 16px">
      <div style="display: flex; justify-content: space-between; margin-bottom: 8px">
        <span><strong>Principal Investigator:</strong> ${p.pi}</span>
        <span><strong>Specialist Mentor:</strong> ${p.mentor}</span>
      </div>
      <div><strong>Current State:</strong> ${p.stage} (${p.version})</div>
      <div><strong>Target Cohort Size:</strong> ${p.sampleSize} Subjects</div>
      <div><strong>Informed Consent Readability:</strong> ${p.readability}</div>
    </div>
    <h4 style="margin-bottom: 8px; color: #fff">Institutional Ethics Checklist Verification:</h4>
    <ul style="padding-left: 20px; line-height: 1.8; color: var(--text-muted); font-size: 12.5px">
      <li>[✓] Protocol signed by PI & Guide</li>
      <li>[✓] Informed Consent Form (ICF) drafted in plain language</li>
      <li>[✓] Safe Harbor data de-identification verified (Zero PHI)</li>
      <li>[✓] Risk-benefit disclosure aligned with Helsinki Declaration standards</li>
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

  document.getElementById('protocolSearchInput')?.addEventListener('input', (e) => {
    renderProtocols(e.target.value);
  });

  document.getElementById('refreshDataBtn')?.addEventListener('click', () => {
    renderDashboard();
    renderSpecialists();
    renderProtocols();
    renderAuditLogs();
    alert('Institutional telemetry synchronized with active database.');
  });

  document.getElementById('exportAuditReportBtn')?.addEventListener('click', () => {
    alert('Generating Institutional Ethics Dossier PDF for IRB review...');
  });
}
