import 'dart:math';
import 'package:Wow/pages/polls_page/model/poll_model.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/utils.dart';

class PollService {
  PollService._();
  static final PollService instance = PollService._();

  // Local storage keys
  static const String _pollsKey = 'local_polls';
  static const String _votersKey = 'local_poll_voters'; // { pollId: [userId, ...] }

  List<Map<String, dynamic>> _readRawPolls() {
    final raw = Database.localStorage.read(_pollsKey);
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> _writeRawPolls(List<Map<String, dynamic>> polls) async {
    await Database.localStorage.write(_pollsKey, polls);
  }

  Map<String, List<String>> _readVoters() {
    final raw = Database.localStorage.read(_votersKey);
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), List<String>.from(value as List)));
    }
    return <String, List<String>>{};
  }

  Future<void> _writeVoters(Map<String, List<String>> voters) async {
    await Database.localStorage.write(_votersKey, voters);
  }

  Future<void> createPoll({
    required String question,
    required List<String> options,
    Duration? duration,
  }) async {
    final now = DateTime.now();
    final expiresAt = duration == null ? null : now.add(duration);
    final random = Random();
    final localId = 'poll_${now.microsecondsSinceEpoch}_${random.nextInt(1 << 32)}';

    // Build PollModel and persist
    final model = PollModel(
      id: localId,
      question: question,
      options: options,
      votes: List<int>.filled(options.length, 0),
      createdAt: now,
      expiresAt: expiresAt,
      createdBy: Database.loginUserId,
    );

    final existing = _readRawPolls();
    existing.insert(0, {
      'id': model.id,
      ...model.toMap(),
    });
    await _writeRawPolls(existing);
    Utils.showLog('Poll created locally with id: $localId');
  }

  Future<List<PollModel>> fetchActivePolls() async {
    final raw = _readRawPolls();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final active = raw.where((m) {
      final exp = m['expiresAt'];
      return exp == null || (exp is int && exp > nowMs);
    }).toList();
    return active.map((m) {
      final id = (m['id'] ?? '').toString();
      return PollModel.fromMap(id, m);
    }).toList();
  }

  Future<void> vote({required String pollId, required int optionIndex}) async {
    // Enforce one vote per user locally
    final voters = _readVoters();
    final userId = Database.loginUserId.isEmpty ? Database.identity : Database.loginUserId;
    final votedUsers = voters[pollId] ?? <String>[];
    if (votedUsers.contains(userId)) {
      Utils.showLog('User already voted for poll: $pollId');
      return;
    }

    final raw = _readRawPolls();
    final index = raw.indexWhere((m) => (m['id'] ?? '') == pollId);
    if (index == -1) return;
    final m = Map<String, dynamic>.from(raw[index]);
    final List<int> votes = List<int>.from((m['votes'] ?? <int>[]).map((e) => (e as num).toInt()));
    if (optionIndex < 0 || optionIndex >= votes.length) return;
    votes[optionIndex] = votes[optionIndex] + 1;
    m['votes'] = votes;
    raw[index] = m;
    await _writeRawPolls(raw);

    votedUsers.add(userId);
    voters[pollId] = votedUsers;
    await _writeVoters(voters);
  }
}


