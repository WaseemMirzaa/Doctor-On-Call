import 'package:dr_on_call/app/modules/favourites/views/mini_widgets/favourites_header.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widgets/background_container.dart';
import '../controllers/favourites_controller.dart';
import 'mini_widgets/favorites_list.dart';

class FavouritesView extends GetView<FavouritesController> {
  const FavouritesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Column(
          children: [
            FavouritesHeader(),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: const FavoritesList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
