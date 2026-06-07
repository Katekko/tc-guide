import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tc_flutter_web/features/guides/presentation/widgets/guide_kit.dart';

void main() {
  goldenTest(
    'guide kit renders panels, callouts and lists',
    fileName: 'guide_panel',
    builder: () => GoldenTestGroup(
      columnWidthBuilder: (_) => const FixedColumnWidth(360),
      children: [
        GoldenTestScenario(
          name: 'panel with bullet list',
          child: GuidePanel(
            title: 'Quick Start',
            body: 'A simple first route for new players.',
            child: BulletGuideList(items: ['First step', 'Second step']),
          ),
        ),
        GoldenTestScenario(
          name: 'callout',
          child: GuideCallout(
            title: 'UR Scroll Discipline',
            text: 'Do not spend UR scrolls casually across every banner.',
          ),
        ),
        GoldenTestScenario(
          name: 'numbered list',
          child: NumberedGuideList(items: ['One', 'Two', 'Three']),
        ),
      ],
    ),
  );
}
