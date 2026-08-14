import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/comment_item.dart';
import '../../../providers/activity_provider.dart';

class CommentSection extends StatefulWidget {
  final String imdbId;
  const CommentSection({super.key, required this.imdbId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();
  bool _hasSpoiler = false;
  final Set<String> _revealedSpoilers = {};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();

    await context.read<ActivityProvider>().postComment(widget.imdbId, text, _hasSpoiler);
    _commentController.clear();
    setState(() => _hasSpoiler = false);
  }

  @override
  Widget build(BuildContext context) {
    final comments = context.watch<ActivityProvider>().comments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reviews & Discussion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Write a review or opinion...',
          ),
        ),
        Row(
          children: [
            Checkbox(
              value: _hasSpoiler,
              activeColor: Colors.amber,
              onChanged: (val) => setState(() => _hasSpoiler = val ?? false),
            ),
            const Text('Contains Spoilers', style: TextStyle(fontSize: 13)),
            const Spacer(),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Post'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (comments.isEmpty)
          const Text('No reviews yet. Be the first to share your thoughts!', style: TextStyle(color: Colors.white54)),
        ...comments.map((comment) {
          final isRevealed = _revealedSpoilers.contains(comment.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        child: Icon(Icons.person, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(comment.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(
                        '${comment.createdAt.year}-${comment.createdAt.month.toString().padLeft(2, '0')}-${comment.createdAt.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (comment.hasSpoiler && !isRevealed)
                    InkWell(
                      onTap: () => setState(() => _revealedSpoilers.add(comment.id)),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                            SizedBox(width: 6),
                            Text('Contains Spoiler. Tap to reveal.', style: TextStyle(color: Colors.amber, fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(comment.text, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}