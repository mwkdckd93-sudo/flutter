import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/question_model.dart';

/// Q&A Section Widget for Auction
class QnaSectionWidget extends StatefulWidget {
  final List<QuestionModel> questions;
  final String currentUserId;
  final String sellerId;
  final int maxQuestionsPerUser;
  final bool isAuctionActive;
  final Function(String) onAskQuestion;
  final Function(String questionId, String answer)? onAnswerQuestion;

  const QnaSectionWidget({
    super.key,
    required this.questions,
    required this.currentUserId,
    required this.sellerId,
    this.maxQuestionsPerUser = 2,
    this.isAuctionActive = true,
    required this.onAskQuestion,
    this.onAnswerQuestion,
  });

  @override
  State<QnaSectionWidget> createState() => _QnaSectionWidgetState();
}

class _QnaSectionWidgetState extends State<QnaSectionWidget> {
  final _questionController = TextEditingController();
  bool _isSubmitting = false;

  int get _userQuestionCount =>
      widget.questions.where((q) => q.askerId == widget.currentUserId).length;

  bool get _canAskQuestion =>
      widget.isAuctionActive &&
      _userQuestionCount < widget.maxQuestionsPerUser &&
      widget.currentUserId != widget.sellerId;

  bool get _isSeller => widget.currentUserId == widget.sellerId;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الأسئلة والأجوبة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'يمكن لكل مستخدم طرح ${widget.maxQuestionsPerUser} أسئلة كحد أقصى',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Ask question input
        if (_canAskQuestion) ...[
          _buildQuestionInput(),
          const SizedBox(height: 16),
        ] else if (!widget.isAuctionActive) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text(
                  'لا يمكن طرح أسئلة بعد انتهاء المزاد',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ] else if (_userQuestionCount >= widget.maxQuestionsPerUser) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.secondaryDark),
                SizedBox(width: 8),
                Text(
                  'لقد وصلت للحد الأقصى من الأسئلة',
                  style: TextStyle(color: AppColors.secondaryDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Questions list
        if (widget.questions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.question_answer_outlined,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'لا توجد أسئلة بعد',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _QuestionCard(
                question: widget.questions[index],
                isSeller: _isSeller,
                onAnswer: widget.onAnswerQuestion != null
                    ? (answer) => widget.onAnswerQuestion!(
                          widget.questions[index].id,
                          answer,
                        )
                    : null,
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuestionInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'اطرح سؤالاً (${_userQuestionCount}/${widget.maxQuestionsPerUser})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _questionController,
            maxLines: 2,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: 'اكتب سؤالك هنا...',
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitQuestion,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: 18),
              label: const Text('إرسال'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() => _isSubmitting = true);

    await widget.onAskQuestion(question);

    setState(() {
      _isSubmitting = false;
      _questionController.clear();
    });
  }
}

class _QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final bool isSeller;
  final Function(String)? onAnswer;

  const _QuestionCard({
    required this.question,
    required this.isSeller,
    this.onAnswer,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _isAnswering = false;
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.question.askerName ?? 'مستخدم',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          DateTimeUtils.getRelativeTimeArabic(widget.question.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.question.question,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Answer
          if (widget.question.isAnswered) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(right: 44),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront, size: 16, color: AppColors.success),
                      const SizedBox(width: 6),
                      const Text(
                        'البائع',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                      const Spacer(),
                      if (widget.question.answeredAt != null)
                        Text(
                          DateTimeUtils.getRelativeTimeArabic(widget.question.answeredAt!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.question.answer!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ] else if (widget.isSeller && widget.onAnswer != null) ...[
            const SizedBox(height: 12),
            if (_isAnswering)
              Container(
                margin: const EdgeInsets.only(right: 44),
                child: Column(
                  children: [
                    TextField(
                      controller: _answerController,
                      maxLines: 2,
                      maxLength: 300,
                      decoration: const InputDecoration(
                        hintText: 'اكتب إجابتك...',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _isAnswering = false),
                          child: const Text('إلغاء'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_answerController.text.trim().isNotEmpty) {
                              widget.onAnswer!(_answerController.text.trim());
                              setState(() => _isAnswering = false);
                            }
                          },
                          child: const Text('إرسال الإجابة'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _isAnswering = true),
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('إجابة'),
                ),
              ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(right: 44),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'في انتظار رد البائع',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
