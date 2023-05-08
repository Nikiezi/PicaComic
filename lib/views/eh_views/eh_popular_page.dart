import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pica_comic/eh_network/eh_main_network.dart';
import 'package:pica_comic/eh_network/eh_models.dart';
import 'package:pica_comic/views/eh_views/eh_widgets/eh_gallery_tile.dart';
import 'package:pica_comic/views/widgets/list_loading.dart';
import '../../base.dart';
import '../widgets/show_network_error.dart';

class EhPopularPageLogic extends GetxController{
  bool loading = true;
  Galleries? galleries;

  void getGallery() async{
    galleries = await EhNetwork().getGalleries("${EhNetwork().ehBaseUrl}/popular");
    loading = false;
    update();
  }

  void retry(){
    loading = true;
    update();
  }

  void refresh_(){
    galleries = null;
    loading = true;
    update();
  }
}

class EhPopularPage extends StatelessWidget {
  const EhPopularPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EhPopularPageLogic>(
      builder: (logic){
        if(logic.loading){
          logic.getGallery();
          return const Center(
            child: CircularProgressIndicator(),
          );
        }else if(logic.galleries!=null){
          return RefreshIndicator(
            child: CustomScrollView(
              slivers: [
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                      childCount: logic.galleries!.length,
                          (context, i){
                        if(i==logic.galleries!.length-1){
                          EhNetwork().getNextPageGalleries(logic.galleries!).then((v)=>logic.update());
                        }
                        return EhGalleryTile(logic.galleries![i]);
                      }
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: comicTileMaxWidth,
                    childAspectRatio: comicTileAspectRatio,
                  ),
                ),
                if(logic.galleries!.next!=null)
                  const SliverToBoxAdapter(
                    child: ListLoadingIndicator(),
                  ),
              ],
            ),
            onRefresh: ()async => logic.refresh_(),
          );
        }else{
          return showNetworkError(context, logic.retry, showBack:false, eh: true);
        }
      },
    );
  }
}
