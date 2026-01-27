import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../../../core/models/quiz_model.dart';
import '../../../data/repositories/quiz_repository.dart';

class QuizPlayPage extends StatefulWidget {
  final QuizModel quiz;

  const QuizPlayPage({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _quizCompleted = false;
  bool _isSubmitting = false;

  final QuizRepository _quizRepository = QuizRepository();

  @override
  void initState() {
    super.initState();
    if (widget.quiz.isCompleted) {
      _score = widget.quiz.score;
      // Start in review mode (show questions, but disable interaction)
      // _quizCompleted defaults to false, which is what we want for showing questions.
      // We rely on _isReviewMode getter.
    }
  }

  bool get _isReviewMode => widget.quiz.isCompleted;

  void _selectAnswer(int index) {
    if (_quizCompleted || _isReviewMode) return;
    setState(() {
      _selectedAnswer = index;
    });
  }

  Future<void> _submitQuizResult() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _quizRepository.submitQuiz(
          widget.quiz.quizId ?? '', _score, widget.quiz.questions);

      setState(() {
        _quizCompleted = true;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim hasil kuis: $e')),
        );
      }
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildCompletionScreen();
    }

    // ... (rest of build logic same as before until AppBar)

    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _isReviewMode ? Colors.grey[800] : AppColors.primary,
        elevation: 0,
        title: Text(
          _isReviewMode ? 'Review Quiz' : widget.quiz.title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) /
                      widget.quiz.questions.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _isReviewMode ? Colors.grey : AppColors.primary),
                  minHeight: 6,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Review Mode Indicator
                        if (_isReviewMode)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.blue.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Mode Review: Jawaban Anda ditandai.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Question
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            currentQuestion.question,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Options
                        ...List.generate(
                          currentQuestion.options.length,
                          (index) => _buildOptionCard(
                            currentQuestion.options[index],
                            index,
                            currentQuestion,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Next button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isReviewMode
                            ? _nextQuestion
                            : (_selectedAnswer != null
                                ? () => _nextQuestion()
                                : null), // Fix recursive call issue
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isReviewMode
                              ? Colors.grey[800]
                              : AppColors.primary,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentQuestionIndex <
                                  widget.quiz.questions.length - 1
                              ? 'Lanjut'
                              : (_isReviewMode ? 'Tutup Review' : 'Selesai'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOptionCard(String option, int index, QuizQuestion question) {
    // Logic for styling options in Play vs Review mode
    bool isSelected = false;
    Color borderColor = Colors.grey.shade300;
    Color backgroundColor = Colors.white;
    Color iconColor = Colors.grey.shade200;
    IconData? iconData;

    if (_isReviewMode) {
      // Review Mode Logic
      final correctIndex = question.correctOptionIndex;
      final userSelectedIndex = question.selectedOptionIndex;

      if (index == correctIndex) {
        // Correct answer - always green
        borderColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
        iconColor = Colors.green;
        iconData = Icons.check_circle;
      } else if (index == userSelectedIndex) {
        // Wrong answer selected by user - red
        borderColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.1);
        iconColor = Colors.red;
        iconData = Icons.cancel;
      }
    } else {
      // Play Mode Logic
      isSelected = _selectedAnswer == index;
      if (isSelected) {
        borderColor = AppColors.primary;
        backgroundColor = AppColors.primary.withOpacity(0.1);
        iconColor = AppColors.primary;
        iconData = Icons.check_circle;
      }
    }

    return GestureDetector(
      onTap: _isReviewMode ? null : () => _selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: (_isReviewMode &&
                        (index == question.correctOptionIndex ||
                            index == question.selectedOptionIndex)) ||
                    (_selectedAnswer == index)
                ? 2
                : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor,
              ),
              child: Center(
                child: iconData != null
                    ? Icon(iconData, size: 20, color: Colors.white)
                    : Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: (iconData != null || isSelected)
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final totalPoints = widget.quiz.totalPoints > 0
        ? widget.quiz.totalPoints
        : widget.quiz.questions.length * 10; // Fallback
    final percentage =
        (totalPoints > 0) ? (_score / totalPoints * 100).round() : 0;
    final isPassed = percentage >= 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: isPassed ? Colors.green : Colors.orange,
        elevation: 0,
        title: const Text(
          'Quiz Selesai',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (isPassed ? Colors.green : Colors.orange)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed ? Icons.emoji_events : Icons.celebration,
                  size: 60,
                  color: isPassed ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                isPassed ? 'Selamat!' : 'Bagus!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Score display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$percentage',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? Colors.green : Colors.orange,
                          ),
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Poin Kamu: $_score / $totalPoints',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kamu menjawab dengan benar.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Daftar Quiz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
