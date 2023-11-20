import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:budget_tracker/amplifyconfiguration.dart';
import 'package:budget_tracker/models/BudgetEntry.dart';
import 'package:budget_tracker/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const MyApp());
}

Future<void> _configureAmplify() async {
  try {
    // Create the API plugin
    // If ModelProvider.instance is not available, try running
    // `amplify codegen models` from the root of project
    final api = AmplifyAPI(modelProvider: ModelProvider.instance);

    // Create the Auth plugin
    final auth = AmplifyAuthCognito();

    // Add the plugins and configure Amplify for app
    await Amplify.addPlugins([api, auth]);
    await Amplify.configure(amplifyconfig);

    safePrint('Successfully configured amplify');
  } on Exception catch (e) {
    safePrint('Error configuring amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen())
  ]);

  @override
  Widget build(BuildContext context) {
    return Authenticator(
        child: MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: Authenticator.builder(),
    ));
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _budgetEntries = <BudgetEntry>[];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refreshBudgetEntries() async {
    // to be filled in
  }
  Future<void> _deleteBudgetEntry({BudgetEntry? budgetEntry}) async {
    // to be filled in
  }

  Future<void> _navigateToBudgetEntry({BudgetEntry? budgetEntry}) async {
    // to be filled in
  }

  double _calculateTotalBudget(List<BudgetEntry?> items) {
    var totalAmount = 0.0;
    for (final item in items) {
      totalAmount += item?.amount ?? 0;
    }
    return totalAmount;
  }

  Widget _buildRow(
      {required String title,
      required String description,
      required String amount,
      TextStyle? style}) {
    return Row(
      children: [
        Expanded(child: Text(title, textAlign: TextAlign.center, style: style)),
        Expanded(
            child:
                Text(description, textAlign: TextAlign.center, style: style)),
        Expanded(child: Text(amount, textAlign: TextAlign.center, style: style))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: _navigateToBudgetEntry, child: const Icon(Icons.add)),
        appBar: AppBar(title: const Text('Budget Tracker')),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.only(top: 25),
                child: RefreshIndicator(
                    onRefresh: _refreshBudgetEntries,
                    child: Column(children: [
                      if (_budgetEntries.isEmpty)
                        const Text(
                            'Use the \u002b sign to add new budget entries')
                      else
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  'Total Budget: \$ ${_calculateTotalBudget(_budgetEntries).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 24)),
                            ]),
                      const SizedBox(height: 30),
                      _buildRow(
                          title: 'Title',
                          description: 'Description',
                          amount: 'Amount',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Divider(),
                      Expanded(
                          child: ListView.builder(
                              itemCount: _budgetEntries.length,
                              itemBuilder: (context, index) {
                                final budgetEntry = _budgetEntries[index];
                                return Dismissible(
                                    key: ValueKey(budgetEntry),
                                    background: const ColoredBox(
                                        color: Colors.red,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(Icons.delete,
                                                  color: Colors.white)),
                                        )),
                                    onDismissed: (_) => _deleteBudgetEntry(
                                        budgetEntry: budgetEntry),
                                    child: ListTile(
                                        onTap: () => _navigateToBudgetEntry(
                                            budgetEntry: budgetEntry),
                                        title: _buildRow(
                                            title: budgetEntry.title,
                                            description:
                                                budgetEntry.description ?? '',
                                            amount:
                                                '\$ ${budgetEntry.amount.toStringAsFixed(2)}')));
                              }))
                    ])))));
  }
}
