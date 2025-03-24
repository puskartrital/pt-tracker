import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pt_tracker/models/task_analytics.dart';
import 'package:pt_tracker/providers/task_provider.dart';
import 'package:pt_tracker/providers/language_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final analytics = TaskAnalytics.fromTasks(taskProvider.allTasks);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.getLocalizedText('Task Insights', 'कार्य विश्लेषण')
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductivityCard(context, analytics),
            const SizedBox(height: 24),
            _buildCompletionChart(context, analytics),
            const SizedBox(height: 24),
            _buildSeverityDistribution(context, analytics),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityCard(BuildContext context, TaskAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Score',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      value: analytics.productivityScore / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProductivityColor(analytics.productivityScore),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${analytics.productivityScore.toInt()}',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        'out of 100',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... Add _buildCompletionChart and _buildSeverityDistribution methods
}
