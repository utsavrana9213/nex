import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Wow/pages/polls_page/model/poll_model.dart';
import 'package:Wow/utils/utils.dart';

class PollService {
  PollService._();
  static final PollService instance = PollService._();

  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('polls');

  Future<void> createPoll({
    required String question,
    required List<String> options,
    Duration? duration,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = duration == null ? null : now.add(duration);
      final doc = await _collection.add({
        'question': question,
        'options': options,
        'votes': List<int>.filled(options.length, 0),
        'createdAt': now.millisecondsSinceEpoch,
        'expiresAt': expiresAt?.millisecondsSinceEpoch,
      });
      await doc.update({'id': doc.id});
      Utils.showLog('Poll created with id: ${doc.id}');
    } on FirebaseException catch (e) {
      Utils.showLog('Firestore createPoll error: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      Utils.showLog('createPoll unexpected error: $e');
      rethrow;
    }
  }

  Future<List<PollModel>> fetchActivePolls() async {
    try {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final query = await _collection.get();
      final docs = query.docs.where((d) {
        final exp = d.data()['expiresAt'];
        return exp == null || exp > nowMs;
      }).toList();
      return docs
          .map((d) => PollModel.fromMap(d.id, d.data()))
          .toList();
    } on FirebaseException catch (e) {
      Utils.showLog('Firestore fetchActivePolls error: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      Utils.showLog('fetchActivePolls unexpected error: $e');
      rethrow;
    }
  }

  Future<void> vote({required String pollId, required int optionIndex}) async {
    final docRef = _collection.doc(pollId);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snap = await transaction.get(docRef);
        if (!snap.exists) return;
        final data = snap.data() as Map<String, dynamic>;
        final List<dynamic> rawVotes = (data['votes'] ?? <int>[]);
        final List<int> votes = rawVotes.map((e) => (e as num).toInt()).toList();
        if (optionIndex < 0 || optionIndex >= votes.length) return;
        votes[optionIndex] = votes[optionIndex] + 1;
        transaction.update(docRef, {'votes': votes});
      });
    } on FirebaseException catch (e) {
      Utils.showLog('Firestore vote error: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      Utils.showLog('vote unexpected error: $e');
      rethrow;
    }
  }
}


