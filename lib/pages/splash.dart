import 'package:biblechamps/services/database.dart';
import 'package:biblechamps/services/ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 6, vsync: this);

    Future.delayed(const Duration(milliseconds: 3000)).then((_) {
      tabController?.animateTo(1);
    });

    Future.delayed(const Duration(milliseconds: 5000)).then((_) {
      tabController?.animateTo(2);
    });

    Future.delayed(const Duration(milliseconds: 7000)).then((_) {
      tabController?.animateTo(3);
    });

    Future.delayed(const Duration(milliseconds: 9000)).then((_) {
      tabController?.animateTo(4);
    });

    Future.delayed(const Duration(milliseconds: 11000)).then((_) {
      tabController?.animateTo(5);
    });

    Future.delayed(const Duration(milliseconds: 13000)).then((_) async {
      if (DatabaseService.launchUrl) {
        if (await canLaunch(DatabaseService().resourceUrl!)) {
          await launch(DatabaseService().resourceUrl!);
        }
      }

      UiService().nextPage(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(6, (int index) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash-${index + 1}.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          );
        }),
      ),
    );
  }
}
