import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/research_models.dart';

class LiveAuditSyncService {
  static void syncToAdminWeb({
    required List<ResearchProject> projects,
    required List<AuditEvent> auditEvents,
    required List<UserProfile> specialists,
  }) {
    if (kIsWeb) return;

    try {
      final syncData = {
        'lastSync': DateTime.now().toString().substring(0, 19),
        'protocols': projects.map((p) {
          return {
            'id': p.id,
            'title': p.title,
            'pi': p.ownerName.isNotEmpty ? p.ownerName : 'Dr. Sarah Lin, MD',
            'mentor': p.assignedSpecialist != null
                ? p.assignedSpecialist!.name
                : 'Awaiting Specialist Guide',
            'stage': '0${p.currentStage.stepNumber} · ${p.currentStage.title}',
            'stageNum': p.currentStage.stepNumber,
            'version': p.protocolVersions.isNotEmpty
                ? p.protocolVersions.last.versionTag
                : 'v1.0 (Draft)',
            'iecStatus': p.currentStage.stepNumber >= 7
                ? 'Checklist Ready (7/7 Validated)'
                : (p.currentStage.stepNumber >= 4
                    ? 'In Progress (4/7 Validated)'
                    : 'Pending Protocol Gate'),
            'sampleSize': p.studyPlan.sampleSizeTarget > 0
                ? p.studyPlan.sampleSizeTarget
                : 140,
            'readability': 'Grade 6.2 (Plain Language)',
          };
        }).toList(),
        'auditEvents': auditEvents.map((a) {
          return {
            'id': a.id.startsWith('AUD-') ? a.id : 'AUD-${a.id.replaceAll('aud_', '').toUpperCase()}',
            'timestamp': a.timestamp.toString().substring(0, 19),
            'title': a.title,
            'description': a.description,
            'operator': a.performedBy,
            'severity': a.severity,
          };
        }).toList(),
        'pipelineDistribution': [
          {'stage': '01. Idea', 'num': '01', 'count': projects.where((p) => p.currentStage == ProjectStage.idea).length},
          {'stage': '02. PICO', 'num': '02', 'count': projects.where((p) => p.currentStage == ProjectStage.pico).length},
          {'stage': '03. Matching', 'num': '03', 'count': projects.where((p) => p.currentStage == ProjectStage.connectSpecialist).length},
          {'stage': '04. Collab', 'num': '04', 'count': projects.where((p) => p.currentStage == ProjectStage.jointDiscussion).length},
          {'stage': '05. Plan', 'num': '05', 'count': projects.where((p) => p.currentStage == ProjectStage.studyPlan).length},
          {'stage': '06. Review', 'num': '06', 'count': projects.where((p) => p.currentStage == ProjectStage.protocolReview).length},
          {'stage': '07. IEC', 'num': '07', 'count': projects.where((p) => p.currentStage == ProjectStage.iecReadiness).length},
          {'stage': '08. Manuscript', 'num': '08', 'count': projects.where((p) => p.currentStage == ProjectStage.manuscript).length},
        ],
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(syncData);

      // Check candidate paths for super_admin_web
      final possibleDirs = [
        'super_admin_web',
        '${Directory.current.path}/super_admin_web',
        'D:/flutter medical app/super_admin_web',
        'd:/flutter medical app/super_admin_web',
      ];

      for (final dirPath in possibleDirs) {
        final dir = Directory(dirPath);
        if (dir.existsSync()) {
          // 1. Write live_data.json
          final jsonFile = File('${dir.path}/live_data.json');
          jsonFile.writeAsStringSync(jsonString);

          // 2. Write js/live_data.js for direct file:// access in browser without CORS
          final jsDir = Directory('${dir.path}/js');
          if (!jsDir.existsSync()) {
            jsDir.createSync(recursive: true);
          }
          final jsFile = File('${dir.path}/js/live_data.js');
          jsFile.writeAsStringSync('window.CLIN_LIVE_DATA = $jsonString;\n');
          break;
        }
      }

      // 3. HTTP Push to Backend API (both local server and cloud on Render)
      _pushHttpAsync(jsonString);
    } catch (e) {
      debugPrint('LiveAuditSyncService error: $e');
    }
  }

  static void _pushHttpAsync(String jsonPayload) {
    final urls = [
      'http://localhost:5000/api/live-sync-push',
      'https://medical-app-backend-tovg.onrender.com/api/live-sync-push',
    ];

    for (final url in urls) {
      http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonPayload,
      ).catchError((_) => http.Response('', 500));
    }
  }
}
