import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tc_flutter_web/core/config/contact_config.dart';
import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/feedback_category.dart';
import '../../domain/entities/feedback_request.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../cubit/feedback_cubit.dart';
import 'contact_links_row.dart';

/// Resolves the localized label for a [FeedbackCategory].
String feedbackCategoryLabel(AppLocalizations l10n, FeedbackCategory category) {
  switch (category) {
    case FeedbackCategory.feature:
      return l10n.feedbackCategoryFeature;
    case FeedbackCategory.bug:
      return l10n.feedbackCategoryBug;
    case FeedbackCategory.fix:
      return l10n.feedbackCategoryFix;
    case FeedbackCategory.guide:
      return l10n.feedbackCategoryGuide;
  }
}

/// The feedback / request form, presented as a modal bottom sheet.
///
/// Owns its text controllers and a [ValueNotifier] for the selected category so
/// it never calls `setState` (per AGENTS.md). Submission state lives in a
/// [FeedbackCubit] provided by [show].
class FeedbackSheet extends StatefulWidget {
  /// Creates the feedback sheet body.
  const FeedbackSheet({
    required this.initialCategory,
    this.pageRoute,
    super.key,
  });

  /// Category preselected when the sheet opens.
  final FeedbackCategory initialCategory;

  /// Route the visitor was on, attached to the message automatically.
  final String? pageRoute;

  /// Opens the feedback sheet, wiring up a fresh [FeedbackCubit].
  static Future<void> show(
    BuildContext context, {
    FeedbackCategory initialCategory = FeedbackCategory.feature,
    String? pageRoute,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sectionBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => FeedbackCubit(sl<FeedbackRepository>()),
        child: FeedbackSheet(
          initialCategory: initialCategory,
          pageRoute: pageRoute,
        ),
      ),
    );
  }

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  late final ValueNotifier<FeedbackCategory> _category;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _category = ValueNotifier<FeedbackCategory>(widget.initialCategory);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _category.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    context.read<FeedbackCubit>().submit(
          FeedbackRequest(
            title: _titleController.text.trim(),
            category: _category.value,
            body: _messageController.text.trim(),
            email: email.isEmpty ? null : email,
            pageRoute: widget.pageRoute,
            locale: Localizations.localeOf(context).toString(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<FeedbackCubit, FeedbackState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == FeedbackStatus.success) {
          Navigator.of(context).pop();
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.feedbackSuccess)),
          );
        } else if (state.status == FeedbackStatus.failure) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.feedbackError)),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _grabber(),
                    const SizedBox(height: 12),
                    Text(
                      l10n.feedbackTitle,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.feedbackSubtitle,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _categoryField(l10n),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: _decoration(
                        label: l10n.feedbackTitleLabel,
                        hint: l10n.feedbackTitleHint,
                      ),
                      style: const TextStyle(color: AppColors.primaryText),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? l10n.feedbackErrorTitleRequired
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoration(
                        label: l10n.feedbackEmailLabel,
                        hint: l10n.feedbackEmailHint,
                      ),
                      style: const TextStyle(color: AppColors.primaryText),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return null;
                        return _emailPattern.hasMatch(email)
                            ? null
                            : l10n.feedbackErrorInvalidEmail;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: _decoration(
                        label: l10n.feedbackMessageLabel,
                        hint: l10n.feedbackMessageHint,
                      ),
                      style: const TextStyle(color: AppColors.primaryText),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? l10n.feedbackErrorMessageRequired
                              : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 15,
                          color: AppColors.mutedText,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.feedbackPageNotice,
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _submitArea(l10n),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<FeedbackCategory>(
                      valueListenable: _category,
                      builder: (context, category, _) => ContactLinksRow(
                        category: category,
                        title: _titleController.text.trim().isEmpty
                            ? null
                            : _titleController.text.trim(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _grabber() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.cardBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _categoryField(AppLocalizations l10n) {
    return ValueListenableBuilder<FeedbackCategory>(
      valueListenable: _category,
      builder: (context, value, _) => DropdownButtonFormField<FeedbackCategory>(
        initialValue: value,
        dropdownColor: AppColors.cardBackground,
        decoration: _decoration(label: l10n.feedbackCategoryLabel),
        style: const TextStyle(color: AppColors.primaryText),
        items: [
          for (final category in FeedbackCategory.values)
            DropdownMenuItem(
              value: category,
              child: Text(feedbackCategoryLabel(l10n, category)),
            ),
        ],
        onChanged: (selected) {
          if (selected != null) _category.value = selected;
        },
      ),
    );
  }

  Widget _submitArea(AppLocalizations l10n) {
    if (!ContactConfig.isEmailConfigured) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          l10n.feedbackEmailUnavailable,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
        ),
      );
    }

    return BlocBuilder<FeedbackCubit, FeedbackState>(
      builder: (context, state) {
        return FilledButton(
          onPressed: state.isSubmitting ? null : () => _submit(context),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: state.isSubmitting
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(l10n.feedbackSending),
                  ],
                )
              : Text(
                  l10n.feedbackSend,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        );
      },
    );
  }

  InputDecoration _decoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.secondaryText),
      hintStyle: const TextStyle(color: AppColors.mutedText),
      filled: true,
      fillColor: AppColors.cardBackground,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cardHoverBorder),
      ),
    );
  }
}
