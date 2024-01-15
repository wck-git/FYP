import 'package:ckfyp02/view/layout/bottom_nav_bar.dart';
import 'package:ckfyp02/view/layout/input_field.dart';
import 'package:ckfyp02/view/user/user_main.dart';
import 'package:ckfyp02/view/user/user_search_result.dart';
import 'package:flutter/material.dart';
import '../layout/button.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';

class UserSearchView extends StatefulWidget {
  UserSearchView({super.key});

  @override
  State<UserSearchView> createState() => _UserSearchViewState();
}

class _UserSearchViewState extends State<UserSearchView> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        centerTitle: true,
        backgroundColor: Colours.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: ResponsiveLayout(
          narrowLayout: NarrowLayout(),
          wideLayout: WideLayout(),
        ),
      ),
      bottomNavigationBar: UserBottomNavBarView(
        currentIndex: currentIndex,
        onTap: (int index) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserMainView(index: index)));
        },
        isAtMainPage: false,
      ),
    );
  }
}

class NarrowLayout extends StatefulWidget {
  const NarrowLayout({super.key});

  @override
  State<NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // search bar
          Expanded(
            child: Container(
              child: UserNarrowSearchBar(
                controller: searchController,
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ),
          const SizedBox(width: 5.0),
          // search button
          Container(
            child: UserNarrowButton(
              buttonText: "Search",
              color: Colours.primaryColor,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserSearchResultView(
                              searchText: searchController.text.trim(),
                            )));
              },
              isSmallButton: true,
              iconPath: "assets/images/user/search.png",
            ),
          ),
        ],
      ),
    );
  }
}

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
