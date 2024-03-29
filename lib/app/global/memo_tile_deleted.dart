import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:get/get.dart';
import 'package:memotile/app/global/memo.dart';
import 'package:memotile/app/global/palette.dart';

import 'package:memotile/app/modules/home/controllers/home_controller.dart';

class MemoTileDeleted extends GetView<HomeController> {
  const MemoTileDeleted(
      {Key? key,
      this.id,
      this.text,
      this.createdAt,
      this.date,
      this.isDeleteChecked,
      this.isDeleted,
      this.isHardDeleted,
      this.colorValue})
      : super(key: key);

  final int? id;
  final String? text;
  final String? createdAt;
  final String? date;
  final int? isDeleteChecked;
  final int? isDeleted;
  final int? isHardDeleted;
  final int? colorValue;

  @override
  Widget build(BuildContext context) {
    final memo = Flexible(
      child: Column(
        children: [
          //왜인지 타일의 텍스트가 길면 날짜 표시줄과 간격이 벌어지지 않음. 임의로 작성.
          // text!.length >= 30
          //     ? SizedBox(
          //         height: 15,
          //       )
          //     : Container(),
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(0.2, 0.0),
            ).animate(
              CurvedAnimation(
                parent: controller.memoTileAnimationController,
                curve: Curves.easeIn,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: 0, bottom: 8, top: 8, right: 10),
                  child: Align(
                    child: InkWell(
                      onTap: () async {
                        if (isDeleteChecked == 1) {
                          print('is delete: ${isDeleteChecked}');
                          print('is delete id: ${id}');
                          await MemoHelper.updateItemForDelete(id!, 0);
                          controller.refreshDeletedMemo();
                        } else {
                          print('is delete: ${isDeleteChecked}');
                          await MemoHelper.updateItemForDelete(id!, 1);
                          controller.refreshDeletedMemo();
                        }
                      },
                      child: Obx(
                        //체크박스
                        () => AnimatedContainer(
                          curve: Curves.fastOutSlowIn,
                          duration: Duration(seconds: 1),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: controller.isDarkModeOn.value == true
                                ? backgroundDark
                                : backgroundLight,
                          ),
                          child: isDeleteChecked == 1
                              ? Icon(
                                  Icons.check,
                                  color: controller.isDarkModeOn.value == true
                                      ? iconDark
                                      : iconLight,
                                )
                              : Container(),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: InkWell(
                    onLongPress: () {
                      // controller.isEditMode.value = true;
                      // controller.isMemoTileShake.value = true;
                      // controller.colorValue.value = colorValue!;
                      // //홈 화면의 메모 타일의 데이터가 상세 페이지로 옮겨지는 과정 - 1.
                      // //이 파트에서 goToDetail 로 네가지 arguments 를 전달.
                      // print(createdAt);
                      // controller.goToDetail(id!, text!, date!, colorValue!);
                    },
                    onTap: () async{
                      final data = await MemoHelper.getItem(id!);
                      print('Memo Debug ::: $data');
                      // controller.memoTileAnimationController.forward();
                      // Future.delayed(
                      //   Duration(milliseconds: 700),
                      //   () {
                      //     controller.memoTileAnimationController.reverse();
                      //   },
                      // );
                    },
                    child: ShakeWidget(
                      //에딧모드 진입시 흔들리는 애니메이션.
                      //패키지가 구형이므로 미지원 상정해야함.
                      //흔들리는 애니메이션은 에딧모드에서 선택됐을때만.
                      autoPlay: isDeleteChecked == 1 ? true : false,
                      duration: Duration(seconds: 4),
                      shakeConstant: ShakeLittleConstant1(),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: controller.isDarkModeOn.value == true
                                  ? shadowDark
                                  : shadowLight,
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8),
                          color: Color(colorValue!),
                        ),
                        child: Text(
                          text!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    //표면적 삭제된 아이템들은 Container로.
    return isHardDeleted == 1
        ? Container()
        : Padding(
            padding: EdgeInsets.only(right: 32, left: 18, top: 5, bottom: 5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 3,
                    ),
                    //최종적으로 감싸기.
                    memo,
                  ],
                ),
              ],
            ),
          );
  }
}
