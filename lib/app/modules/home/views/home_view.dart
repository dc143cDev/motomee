import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:memotile/app/modules/home/views/control_view.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../global/horizontal_line.dart';
import '../../../global/marker_tile.dart';
import '../../../global/memo_tile.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    const colorizeTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 27,
      fontWeight: FontWeight.w700,
    );

    final appBarTitle = SizedBox(
      width: 250,
      child: AnimatedTextKit(
        animatedTexts: [
          ColorizeAnimatedText(
            'MOTOMEE',
            textStyle: colorizeTextStyle,
            colors: [Colors.black, Colors.red],
          ),
          ColorizeAnimatedText(
            controller.redredTagController.text,
            textStyle: colorizeTextStyle,
            colors: [
              Color(controller.redredValue),
              Color(controller.colorValue.value)
            ],
          ),
        ],
      ),
    );

    final home = GestureDetector(
      onPanUpdate: (i) {
        //왼쪽에서 오른쪽으로 스와이프시 에딧모드.
        if (i.delta.dx > 30) {
          controller.editModeInitAnimation();
        }
      },
      onTap: () {
        //어느 화면이나 눌렀을때 텍스트 필드를 내리기 위해 Gesture Detector 감싸주기.
        controller.textFocus.unfocus();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey[50],
            floatingActionButton: Obx(
              () => Padding(
                padding: controller.isEditMode.value == true
                    ? EdgeInsets.only(bottom: 70)
                    : EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: true,
                      backgroundColor: Colors.grey[200],
                      child: controller.isEditMode.value == true ||
                              controller.searchModeOn.value == true ||
                              controller.tagModeOn.value == true
                          ? Icon(
                              Icons.close,
                              color: Colors.black,
                            )
                          : Icon(
                              Icons.search_rounded,
                              color: Colors.black,
                            ),
                      onPressed: () async {
                        if (controller.isEditMode.value == true ||
                            controller.searchModeOn.value == true ||
                            controller.tagModeOn.value == true) {
                          //에딧모드 종료시 실행되는 메소드.
                          await controller.editModeDone();
                          Future.delayed(Duration(milliseconds: 400), () {
                            controller.defaultModeOn();
                          });
                        } else {
                          // controller.isEditMode.value = true;
                          openSearchSheet();
                        }
                      },
                    ),
                    //스크롤 컨트롤러 offset이 맨 아래가 아니라면 아래로 내리기 버튼을 활성화함.
                    controller.goToDownButtonDontShow.value == true
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: FloatingActionButton(
                              backgroundColor: Colors.grey[200],
                              child: Icon(
                                Icons.arrow_downward_sharp,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                controller.goToDown();
                              },
                            ),
                          ),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              elevation: 0,
              centerTitle: false,
              scrolledUnderElevation: 0,
              // backgroundColor: Colors.white.withOpacity(0.9),
              backgroundColor: Colors.transparent,
              //타이틀도 leading 과 같이 모드 가변형 ui.
              // title: appBarTitle,
              title: Obx(
                () => controller.tagModeOn == true ||
                        controller.searchModeOn == true
                    ? Row(
                        children: [
                          controller.searchModeOn.value == true
                              ? Text(
                                  //서치모드
                                  controller.searchBarController.text,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Text(
                                  //태그모드
                                  controller.tag.read(controller.nowTag.value),
                                  style: TextStyle(
                                    color: Color(controller.colorValue.value),
                                    fontSize: 27,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                          IconButton(
                            onPressed: () {
                              controller.defaultModeOn();
                              controller.refreshMemo();
                            },
                            icon: Icon(
                              Icons.close,
                              size: 30,
                            ),
                          ),
                        ],
                      )
                    //디폴트 모드 or 날짜모드.
                    : controller.dateModeOn.value == true
                        ? Row(
                            children: [
                              Text(
                                //요일
                                controller.selectedDay.value,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  controller.defaultModeOn();
                                  controller.refreshMemo();
                                },
                                icon: Icon(
                                  Icons.close,
                                  size: 30,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            //디폴트 모드 타이틀. 로고.
                            'MOTOMEE',
                            style: TextStyle(
                              // color: Color(controller.ssDayColorValue.value),
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
              ),
            ),
            extendBodyBehindAppBar: true,
            body: Obx(
              () => SafeArea(
                child: controller.memo.toString() == '[]'
                    ? Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                'empty',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 40),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: SizedBox(),
                          ),
                          //textField. empty 상태일때 굳이 필요 없다고 판단.
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: TextFormField(
                                      controller: controller.memoController,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusColor: Colors.black,
                                        hintText: ' Insert here',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0, top: 5, right: 14, bottom: 5),
                                  child: IconButton(
                                    //+ 버튼
                                    //눌렀을 때 addItem 메소드 실행
                                    //->TextField 의 Text, 현재 시간, colorValue 의 값을 db 에 insert
                                    onPressed: () async {
                                      //dateTime 데이터는 원래 '' 이므로 해당 값을 가져와주는 메소드를 먼저 실행.
                                      //공백 입력 방지.
                                      if (controller.memoController.text
                                              .toString() !=
                                          '') {
                                        await controller.getDefaultColor();
                                        await controller.getCurrentDay();
                                        await controller.getCurrentDayDetail();
                                        await controller.getCurrentDate();
                                        await controller.firstCheckByDate();
                                        controller.addItem();
                                        //스크롤 아래로 내리기.
                                        controller.goToDown();
                                        //TextField 초기화.
                                        controller.memoController.clear();
                                        //defaultModeOn
                                        controller.defaultModeOn();
                                        //debug.
                                        print(controller.colorValue.value
                                            .toString());
                                        print(controller.CurrentDayDetail.value
                                            .toString());
                                      }
                                    },
                                    icon: Icon(Icons.arrow_upward),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            flex: controller.isEditMode.value == true ? 8 : 9,
                            child: Obx(
                              () => ListView.builder(
                                shrinkWrap: true,
                                reverse: false,
                                //아이템이 몇개 없어도 스크롤되도록 함.
                                physics: AlwaysScrollableScrollPhysics(),
                                controller: controller.scrollController.value,
                                itemCount: controller.memo.length,
                                itemBuilder: (context, index) {
                                  return MemoTile(
                                    //memo_tile ui 에 들어갈 각 객체를 index 와 column 값을 넣어 구성.
                                    id: controller.memo[index]['id'],
                                    text: controller.memo[index]['content'],
                                    createdAt: controller.memo[index]
                                        ['createdAt'],
                                    isEditChecked: controller.memo[index]
                                        ['isEditChecked'],
                                    date: controller.memo[index]['dateData'],
                                    isFirst: controller.memo[index]['isFirst'],
                                    isDeleted: controller.memo[index]
                                        ['isDeleted'],
                                    colorValue: controller.memo[index]
                                        ['colorValue'],
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: controller.isEditMode.value == true ? 2 : 1,
                            //에딧모드가 켜지면 텍스트필드가 아닌 태그설정 및 지우기 탭이 나옴.
                            child: controller.isEditMode.value == true
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              30, 10, 30, 0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: Offset(0, 3),
                                                  )
                                                ]),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 38,
                                                            width: 38,
                                                            child:
                                                                MaterialButton(
                                                              onPressed:
                                                                  () async {
                                                                await controller
                                                                    .getRedRed();
                                                                controller.editModeCheckedItemColorFill(
                                                                    controller
                                                                        .colorValue
                                                                        .value);
                                                              },
                                                              color: Color(
                                                                  controller
                                                                      .redredValue),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(controller.tag
                                                              .read('red')),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 38,
                                                            width: 38,
                                                            child:
                                                                MaterialButton(
                                                              onPressed:
                                                                  () async {
                                                                await controller
                                                                    .getBlue();
                                                                controller.editModeCheckedItemColorFill(
                                                                    controller
                                                                        .colorValue
                                                                        .value);
                                                              },
                                                              color: Color(
                                                                  controller
                                                                      .blueValue),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(controller.tag
                                                              .read('blue')),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 38,
                                                            width: 38,
                                                            child:
                                                                MaterialButton(
                                                              onPressed:
                                                                  () async {
                                                                await controller
                                                                    .getAqua();
                                                                controller.editModeCheckedItemColorFill(
                                                                    controller
                                                                        .colorValue
                                                                        .value);
                                                              },
                                                              color: Color(
                                                                  controller
                                                                      .aquaValue),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(controller.tag
                                                              .read('aqua')),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 38,
                                                            width: 38,
                                                            child:
                                                                MaterialButton(
                                                              onPressed:
                                                                  () async {
                                                                await controller
                                                                    .getGreen();
                                                                controller.editModeCheckedItemColorFill(
                                                                    controller
                                                                        .colorValue
                                                                        .value);
                                                              },
                                                              color: Color(
                                                                  controller
                                                                      .greenValue),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(controller.tag
                                                              .read('green')),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 38,
                                                            width: 38,
                                                            child:
                                                                MaterialButton(
                                                              onPressed:
                                                                  () async {
                                                                await controller
                                                                    .getPink();
                                                                controller.editModeCheckedItemColorFill(
                                                                    controller
                                                                        .colorValue
                                                                        .value);
                                                              },
                                                              color: Color(
                                                                  controller
                                                                      .pinkValue),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(controller.tag
                                                              .read('pink')),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 38,
                                                            width: 38,
                                                            child:
                                                                MaterialButton(
                                                              onPressed:
                                                                  () async {
                                                                await controller
                                                                    .getOrange();
                                                                controller.editModeCheckedItemColorFill(
                                                                    controller
                                                                        .colorValue
                                                                        .value);
                                                              },
                                                              color: Color(
                                                                  controller
                                                                      .orangeValue),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(controller.tag
                                                              .read('orange')),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 38,
                                                            width: 38,
                                                            child:
                                                                MaterialButton(
                                                              onPressed:
                                                                  () async {
                                                                await controller
                                                                    .getPurple();
                                                                controller.editModeCheckedItemColorFill(
                                                                    controller
                                                                        .colorValue
                                                                        .value);
                                                              },
                                                              color: Color(
                                                                  controller
                                                                      .purpleValue),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(controller.tag
                                                              .read('purple')),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 38,
                                                            width: 38,
                                                            child:
                                                                MaterialButton(
                                                              onPressed:
                                                                  () async {
                                                                await controller
                                                                    .getMustard();
                                                                controller.editModeCheckedItemColorFill(
                                                                    controller
                                                                        .colorValue
                                                                        .value);
                                                              },
                                                              color: Color(
                                                                  controller
                                                                      .mustardValue),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(controller.tag
                                                              .read('mustard')),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0,
                                            top: 5,
                                            right: 14,
                                            bottom: 5),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            controller
                                                .editModeCheckedItemDelete();
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: TextFormField(
                                            focusNode: controller.textFocus,
                                            controller:
                                                controller.memoController,
                                            cursorColor: Colors.black,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              focusColor: Colors.black,
                                              hintText: ' Insert here',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0,
                                            top: 5,
                                            right: 14,
                                            bottom: 5),
                                        child: IconButton(
                                          //+ 버튼
                                          //눌렀을 때 addItem 메소드 실행
                                          //->TextField 의 Text, 현재 시간, colorValue 의 값을 db 에 insert
                                          onPressed: () async {
                                            //dateTime 데이터는 원래 '' 이므로 해당 값을 가져와주는 메소드를 먼저 실행.
                                            //공백 입력 방지.
                                            if (controller.memoController.text
                                                    .toString() !=
                                                '') {
                                              await controller
                                                  .getDefaultColor();
                                              await controller.getCurrentDay();
                                              await controller
                                                  .getCurrentMonthMM();
                                              await controller.getCurrentYear();
                                              await controller
                                                  .getCurrentDayDetail();
                                              await controller.getCurrentDate();
                                              await controller
                                                  .firstCheckByDate();
                                              controller.addItem();
                                              //스크롤 아래로 내리기.
                                              controller.goToDown();
                                              //TextField 초기화.
                                              controller.memoController.clear();
                                              //defaultModeOn
                                              controller.defaultModeOn();
                                              //debug.
                                              print(controller.colorValue.value
                                                  .toString());
                                              print(controller
                                                  .CurrentDayDetail.value
                                                  .toString());
                                            }
                                          },
                                          icon: Icon(Icons.send_rounded),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment(1.0, -0.9),
                child: Container(
                  width: 25,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.9999, -0.939),
                child: Container(
                  width: 40,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.9999, -0.67),
                child: Container(
                  width: 40,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(1.1, -0.83),
                child: Container(
                  width: controller.height * 0.1,
                  height: controller.height * 0.082,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.93, -0.805),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(0, 5),
                      )
                    ],
                  ),
                  child: Container(
                    width: controller.width.value * 0.1 + 3,
                    height: controller.width.value * 0.1,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        controller.pageController.animateToPage(1,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn);
                        //컨트롤 페이지로 넘어갈때 에딧모드 해제. 자연스러운 해제를 위해 딜레이 주기.
                        controller.editModeDone();

                        // if (controller.controllPageContainerAnimationOn.value ==
                        //     false) {
                        //   await controller.controllPageContainerInitAnimation();
                        // } else if (controller
                        //         .controllPageContainerAnimationOn.value ==
                        //     true) {
                        //   controller.getControllPageContainer();
                        // }

                        Future.delayed(Duration(milliseconds: 200), () {
                          controller.isEditMode.value = false;
                        });
                      },
                      icon: Icon(Icons.arrow_back_ios_new_outlined),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    //최종 빌드될 리턴.
    return PageView(
      onPageChanged: (int) async {
        await controller.getTiles();
        if (controller.controllPageContainerAnimationOn.value == false) {
          await controller.controllPageContainerInitAnimation();
        } else if (controller.controllPageContainerAnimationOn.value == true) {
          controller.getControllPageContainer();
        }
        controller.CurrentMonthForTile.value = controller.CurrentMonthMMM.value;
      },
      physics: ClampingScrollPhysics(),
      controller: controller.pageController,
      children: [
        home,
        //컨트롤뷰는 네비게이션 되는게 아니라 사전에 불러와진 뷰를 넘기는것 뿐.
        ControlView(),
      ],
    );
  }

  //타일뷰 바텀시트.
  openTileSheet() async {
    //모드 초기화를 위해 메모 리프레쉬.
    await controller.refreshMemo();
    await controller.defaultModeOn();
    //Tile View 로 넘어가기 전에 memoForEvent 에 월별로 가져온 데이터 넣기.
    await controller.getTiles();
    await controller.goToDown();
    //CurrentMonthForTile 의 초기 값은 '' 이므로 평소에는 타이틀에 아무 값도 나오지 않음.
    controller.CurrentMonthForTile.value = controller.CurrentMonthMMM.value;
    Get.bottomSheet(
      enterBottomSheetDuration: Duration(milliseconds: 200),
      exitBottomSheetDuration: Duration(milliseconds: 200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
      elevation: 0,
      SafeArea(
        child: SizedBox(
          height: 440,
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: 13,
              ),
              Center(
                child: SizedBox(
                  width: 50,
                  height: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Expanded(
                flex: 1,
                child: Obx(
                  () => Text(
                    controller.CurrentMonthForTile.value,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
              Expanded(
                flex: 9,
                child: TableCalendar(
                  calendarBuilders: CalendarBuilders(
                      //마커 타일 빌더.
                      //context 와 날짜(년월일시분초까지 다 표시되는 버전), event(List)를 넘겨줄수 있음.
                      markerBuilder: (context, day, events) {
                    //events 의 원형은 [ 단일객체 ] (length == 1) 이기때문에 두번 걸러 리스트화 해야함.
                    //to String,
                    String eventToString = events.toString();
                    //jsonDecode from String to List.
                    List stringEventToList = jsonDecode(eventToString);
                    if (events.isNotEmpty == true) {
                      return Center(
                        child: MarKerTile(
                          date: '',
                          event: DateFormat('dd').format(day),
                          //그렇게 리스트화된 colorValue 객체 중 하나를 ui에 넣어주기.
                          colorList: stringEventToList,
                          color: stringEventToList.last,
                        ),
                      );
                    }
                    return null;
                  }),
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Colors.red,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(color: Colors.white),
                    titleCentered: true,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                    formatButtonVisible: false,
                  ),
                  eventLoader: (day) {
                    return controller.getEvents(day);
                  },
                  focusedDay: DateTime.now(),
                  firstDay: DateTime(2010, 5, 1),
                  lastDay: DateTime(2033, 12, 31),
                  onDaySelected:
                      (DateTime selectedDay, DateTime focusedDay) async {
                    //DB 검색 용이성을 위해 미리 지정된 포맷으로 selectedDay 반환.
                    await controller.goToTop();
                    controller.selectedDay.value =
                        DateFormat("yyyyMMdd").format(selectedDay);
                    print('$selectedDay is selected');
                    print('$focusedDay is focused');
                    print(controller.selectedDay);
                    controller.refreshMemoByDateTile(controller.selectedDay);
                    controller.dateButtonClicked();
                    controller.goToDown();
                    Get.back();
                  },
                  onPageChanged: (day) {
                    //페이지 전환할때마다 값을 지금이 몇월인지 값 넘겨주기.
                    controller.CurrentMonthForTile.value =
                        DateFormat('MMM').format(day);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //서치 탭 바텀시트.
  openSearchSheet() async {
    //검색버튼을 누르는 순간에 클리어를 두면 앱바 ui에 반영되지 않기에 바텀시트를 불러올때 클리어를 둠.
    controller.searchBarController.clear();
    if (controller.tagModeOn.value == true) {
      controller.refreshMemoByColor(controller.colorValue.value);
    }
    Get.bottomSheet(
      enterBottomSheetDuration: Duration(milliseconds: 200),
      exitBottomSheetDuration: Duration(milliseconds: 200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
      elevation: 0,
      SizedBox(
        height: 340,
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              height: 13,
            ),
            Center(
              child: SizedBox(
                width: 50,
                height: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tags',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed('/tags');
                    },
                    child: Text(
                      'Customizing',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 3, 13, 13),
              child: SizedBox(
                height: 78,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: MaterialButton(
                            onPressed: () async {
                              await controller.getRedRed();
                              controller.nowTag.value = 'red';
                              controller.tagButtonClicked();
                              controller.refreshMemoByColor(
                                  controller.colorValue.value);
                              Get.back();
                            },
                            color: Color(controller.redredValue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(controller.tag.read('red')),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: MaterialButton(
                            onPressed: () async {
                              await controller.getBlue();
                              controller.nowTag.value = 'blue';
                              controller.tagButtonClicked();
                              controller.refreshMemoByColor(
                                  controller.colorValue.value);
                              Get.back();
                            },
                            color: Color(controller.blueValue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(controller.tag.read('blue')),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: MaterialButton(
                            onPressed: () {
                              controller.getAqua();
                              controller.nowTag.value = 'aqua';
                              controller.tagButtonClicked();
                              controller.refreshMemoByColor(
                                  controller.colorValue.value);
                              Get.back();
                            },
                            color: Color(controller.aquaValue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(controller.tag.read('aqua')),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: MaterialButton(
                            onPressed: () {
                              controller.getGreen();
                              controller.nowTag.value = 'green';
                              controller.tagButtonClicked();
                              controller.refreshMemoByColor(
                                  controller.colorValue.value);
                              Get.back();
                            },
                            color: Color(controller.greenValue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(controller.tag.read('green')),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: MaterialButton(
                            onPressed: () {
                              controller.getPink();
                              controller.nowTag.value = 'pink';
                              controller.tagButtonClicked();
                              controller.refreshMemoByColor(
                                controller.colorValue.value,
                              );
                              Get.back();
                            },
                            color: Color(controller.pinkValue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(controller.tag.read('pink')),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: MaterialButton(
                            onPressed: () {
                              controller.getOrange();
                              controller.nowTag.value = 'orange';
                              controller.tagButtonClicked();
                              controller.refreshMemoByColor(
                                  controller.colorValue.value);
                              Get.back();
                            },
                            color: Color(controller.orangeValue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(controller.tag.read('orange')),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: MaterialButton(
                            onPressed: () {
                              controller.getPurple();
                              controller.nowTag.value = 'purple';
                              controller.tagButtonClicked();
                              controller.refreshMemoByColor(
                                  controller.colorValue.value);
                              Get.back();
                            },
                            color: Color(controller.purpleValue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(controller.tag.read('purple')),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: MaterialButton(
                            onPressed: () {
                              controller.getMustard();
                              controller.nowTag.value = 'mustard';
                              controller.tagButtonClicked();
                              controller.refreshMemoByColor(
                                  controller.colorValue.value);
                              Get.back();
                            },
                            color: Color(controller.mustardValue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(controller.tag.read('mustard')),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ),
            HorizontalLine(),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 16,
                ),
                Text(
                  'Searching',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          focusNode: controller.textFocus,
                          controller: controller.searchBarController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () async {
                                await controller.searchButtonClicked();
                                await controller.refreshMemoByContent(
                                  controller.searchBarController.text,
                                );
                                //여기에 클리어를 두면 앱바 ui 수정에 반영되지 않음.
                                // controller.searchBarController.clear();
                                Get.back();
                              },
                              icon: Icon(Icons.search_rounded),
                            ),
                            hintText: ' Insert here',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              color: Get.isDarkMode
                                  ? Colors.grey[200]
                                  : Colors.grey[800],
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (String text) async {
                            //콘텐츠 검색기능 사용시 태그 검색모드 해제
                            controller.tagModeOn.value = false;
                            controller.searchModeOn.value = false;
                            controller.refreshMemoByContent(text);
                          },
                          onTapOutside: (P) {
                            // 태그 검색모드 활성화된 상태라면 바깥 쪽을 터치해도 태그 검색모드가 해제되지 않도록 함.
                            if (controller.tagModeOn.value == false) {
                              controller.refreshMemo();
                            }
                            controller.searchBarController.clear();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  //메뉴 탭 클릭시 오픈.
  openMenuSheet() {
    Get.bottomSheet(
      enterBottomSheetDuration: Duration(milliseconds: 200),
      exitBottomSheetDuration: Duration(milliseconds: 200),
      backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      Column(
        children: [
          SizedBox(
            height: 13,
          ),
          Center(
            child: SizedBox(
              width: 50,
              height: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          InkWell(
            onTap: () async {
              //바텀시트 내리고 테마 뷰로 이동.
              Get.back();
              Get.toNamed('/theme');
            },
            child: Container(
              width: double.infinity,
              height: 70,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.style,
                      color: Get.isDarkMode ? Colors.white : Colors.grey[700],
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Themes and Fonts',
                      style: TextStyle(
                        color: Get.isDarkMode ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          HorizontalLine(),
          InkWell(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 70,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Get.isDarkMode ? Colors.white : Colors.grey[700],
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Infomation and Connect',
                      style: TextStyle(
                        color: Get.isDarkMode ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          HorizontalLine(),
        ],
      ),
    );
  }
}
