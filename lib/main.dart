import 'package:bible_app/style/textstyle.dart';
import 'package:bible_app/textReturn.dart';
import 'package:bible_app/userInfo.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neon/neon.dart';


void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark
      ),
      title: 'bible_app',
      home: TestUi(),
    );
  }
}



class TestUi extends StatefulWidget {

  @override
  _TestUiState createState() => _TestUiState();
}

class _TestUiState extends State<TestUi> {

  Size size;
  List<bool> _isOpened = List<bool>();
  List<String> _title = List<String>();
  List<List<int>> _list = List<List<int>>();
  UserInfo _userInfo;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('user').snapshots(),
      builder:(context, snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 5,
            ),
          );
        }
        List<UserInfo> ui = snapshot.data.docs.map((d)
                  => UserInfo.fromSnapshot(d)).toList();
        if(ui[0].username=='yong'){
          return buildContents(context, ui[0]);
        }
        else{
          return Container(
            child: Text('sdasdasd'),
          );
        }
      },
    );
  }

  Widget buildContents(BuildContext context, UserInfo ui){

    List<bool> isOpened = List<bool>();
    //각 버튼의 제목(어떤 성경인지) // 12개
    List<String> title = List<String>();
    //각 버튼마다 나타날 장 수 [시작하는 장, 장 수]
    List<List<int>> list = List<List<int>>();


    size = MediaQuery.of(context).size;
    print(ui.whichCircle);

    title = ['빌립보서', '골로새서', '에베소서', '갈라디아서', '고린도전서',
    '이사야', '로마서', '사도행전', '요한복음', '요한계시록', '마태복음',
    '로마서'];

    list = [[1,3], [1,3], [4,3], [1,2], [2,2], [9,1], [7,2], [10,2], [3,2],
    [1,2], [1,2], [4,2]];

    for(int i=0; i<title.length; i++){
      if(i<=ui.whichCircle)
        isOpened.add(true);
      else
        isOpened.add(false);
    }

    print('TestUi : ${ui.whichCircle}');

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.2,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical : 20),
                  child: Container(
                    child: CarouselSlider(
                      options: CarouselOptions(
                          enableInfiniteScroll: false,
                          enlargeCenterPage: true,
                          enlargeStrategy: CenterPageEnlargeStrategy.scale,
                          aspectRatio: 1
                      ),
                      items: List.generate(title.length,
                              (index){
                                return Builder(
                                    builder: (BuildContext context){
                                      //전역변수로 안하고 직접 넣어주는 이유
                                      // 페이지가 돌아왔을 때 반영이 되어있음
                                      return MKCard(context, index, isOpened, title, list, ui);
                                    });
                              })
                    ),
                  ),
                ),
                SizedBox(height: size.height*0.02,),
                Camp()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget MKCard(BuildContext context, int index, List<bool> isOpened
      , List<String> title, List<List<int>> list, UserInfo ui){
    return Container(
      width: size.width*0.75,
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        splashColor: Colors.grey[800],
        disabledColor: Colors.grey,
        onPressed: isOpened[index]
            ? () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BibleList(
                        isBc: false,
                        title: title[index],
                        list: list[index],
                        ui: ui,
                        which_index: index)
                )
                );
              }
            : null,
        color: Colors.primaries[index%18],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(child: CustomTextColor(title[index], 30, Colors.white)),
            Stack(
              children: [
                Container(
                  color: Colors.transparent,
                  height: size.height*0.22, width: size.width*0.73,
                  child: Center(
                    child: Container(
                      height: size.height*0.16,width: size.width*0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            child: Container(
                              width: size.width*0.40,
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  MKCircle('근본'),
                                  MKCircle('본체')
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height*0, left: size.width*0.02,
                  child: Container(
                    height: size.height*0.06, width: size.width*0.27,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(19)
                    ),
                    child: Center(
                      child: CustomTextColor('핵심키워드', 20, Colors.white),),
                  ),
                )
              ],
            ),
            Stack(
              children: [
                Container(
                  color: Colors.transparent,
                  height: size.height*0.22, width: size.width*0.73,
                  child: Center(
                    child: Container(
                      height: size.height*0.16,width: size.width*0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Container(
                              width: size.width*0.3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CustomTextColor('<한글>', 14, Colors.black),
                                  SizedBox(height: size.height*0.02,),
                                  Center(
                                    child: CustomTextColor('40%', 30, Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.black,
                            thickness: 3,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              width: size.width*0.3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CustomTextColor('<영어>', 14, Colors.black),
                                  SizedBox(height: size.height*0.02,),
                                  Center(
                                    child: CustomTextColor('50%', 30, Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                     ),
                  ),
                ),
                Positioned(
                  left: size.width*0.015,
                  child: Container(
                    height: size.height*0.06, width: size.width*0.20,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(19)
                    ),
                    child: Center(
                      child: CustomTextColor('반복도', 20, Colors.white),),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // 아래부분 일러스트 나타내는 큰 틀
  Widget Camp(){
    return Container(
      color: Colors.transparent,
      height: size.height*0.275,
      width: size.width*0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LeftCamp('임마누엘교회', '잠실붙박이', Colors.blue),
          NeonText('VS', 15, Colors.red),
          RightCamp('잠실중앙교회', '천호동부자', Colors.purple)
        ],
      ),
    );
  }

  //양대 진영을 나타내는 기능
  Widget LeftCamp(String church, String nickname, Color color){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //교회 부분
        Container(color: Colors.transparent,
          height: size.height*0.25,
          width: size.width*0.07,
          child: VerticalText(church),
        ),
        //일러스트 부분
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.black,
              height: size.height*0.2,
              width: size.width*0.28,
            ),
            Container(
              height: size.height*0.05,
              width: size.width*0.28,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1
                )
              ),
              child: Center(child: NeonText(nickname, 15, color),),
            )
          ],
        ),
      ],
    );
  }

  Widget RightCamp(String church, String nickname, Color color){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //일러스트 부분
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.black,
              height: size.height*0.2,
              width: size.width*0.28,
            ),
            Container(
              height: size.height*0.05,
              width: size.width*0.28,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1
                  )
              ),
              child: Center(child: NeonText(nickname, 15, color),),
            ),
          ],
        ),
        //교회 부분
        Container(color: Colors.transparent,
          height: size.height*0.25,
          width: size.width*0.07,
          child: VerticalText(church),
        ),
      ],
    );
  }


  Widget VerticalText(String text){

    var t = text.split("");

    List<Widget> tt = List<Widget>();
    tt = List.generate(t.length, (index){
      return CustomText('${t[index]}', 14);
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tt,
    );
  }

  Widget MKCircle(String text){
        return Container(
        width: size.width*0.20, height: size.height*0.1,
        child: CircleAvatar(
          backgroundColor: Colors.black,
          child: Center(child: CustomTextColor(text, 20, Colors.white),),
        ),
      );
  }

  Route _createRoute(){

  }
}

class BibleList extends StatefulWidget {

  bool isBc;
  List<int> list;
  String title;
  UserInfo ui;
  int which_index;
  BibleList({this.isBc, this.list, this.title, this.ui, this.which_index});


  @override
  _BibleListState createState() => _BibleListState();
}

class _BibleListState extends State<BibleList> {
  List<String> bc = ['창세기', '출애굽기', '레위기', '민수기', '신명기', '여호수아'
    ,'사사기', '룻기', '사무엘상', '사무엘하', '열왕기상', '열왕기하', '역대상', '역대하'
    , '에스라', '느헤미아', '에스더', '욥기', '시편', '잠언', '전도서'
    ,'아가', '이사야', '예레미야', '예레미아애가', '에스겔', '다니엘', '호세아'
    , '요엘', '아모스', '오바댜', '요나', '미가', '나훔', '하박국', '스바냐'
    , '학개', '스가랴', '말라기'];

  List<String> bc_char = ['창', '출', '레', '민', '신', '수','삿', '룻'
    , '삼상', '삼하', '왕상', '왕하', '대상', '대하', '스', '느', '에', '욥'
    , '시', '잠', '전','아', '사', '렘', '애', '겔', '단', '호', '욜', '암'
    , '옵', '욘', '미', '나', '합', '습', '학', '슥', '말'];

  List<int> bc_num = [50, 40, 27, 36, 34, 24, 21, 4, 31, 24, 22, 25, 29, 36
    , 10, 13, 10, 42, 150, 31, 12, 8, 66, 52, 5, 48, 12, 14, 3, 9, 1, 4, 7
    , 3, 3, 3, 2, 14, 4];

  List<String> ad = ['마태복음', '마가복음', '누가복음', '요한복음', '사도행전'
    , '로마서', '고린도전서', '고린도후서', '갈라디아서', '에베소서', '빌립보서'
    , '골로새서', '데살로니가전서', '데살로니가후서', '디모데전서', '디모데후서'
    , '디도서', '빌레몬서', '히브리서', '야고보서', '베드로전서', '베드로후서'
    , '요한일서', '요한이서', '요한삼서', '유다서', '요한계시록'];

  List<String> ad_char = ['마', '막', '눅', '요', '행', '롬', '고전', '고후'
    , '갈', '엡', '빌', '골', '살전', '살후', '딤전', '딤후', '딛', '몬', '히'
    , '약', '벧전', '벧후', '요일', '요이', '요삼', '유', '계'];

  List<int> ad_num = [28, 16, 24, 21, 28, 16, 16, 13, 6, 6, 4, 4, 5, 3, 6, 4
    , 3, 1, 13, 5, 5, 3, 5, 1, 1, 1, 22];

  //몇장인지 저장
  int result_num=0;
  // 마지막장, 첫장
  int min, max;
  //버튼 열려져 있는지 저장
  List<bool> opened = List<bool>();

  // 범위에 맞는 성경 장수만 버튼형태로 출력
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    print('BibleList : ${widget.ui.whichCircle}');

    //첫페이지, 마지막 페이지
    min = widget.list[0];
    max = widget.list[0]+widget.list[1]-1;
    print('min : ${min}');
    print('max : ${max}');

    for(int num=0; num<ad.length; num++){
      if(widget.title == ad[num])
        result_num = num;
      else if(widget.title == '이사야'){
        widget.isBc = true;
        for(int k=0; k<bc.length; k++){
          if(widget.title == bc[k])
            result_num = k;
        }
      }
    }

      return Scaffold(
      appBar: AppBar(
        title: Text('${widget.isBc?bc[result_num]:ad[result_num]}'),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3
              ),
              itemCount: widget.list[1],
              itemBuilder: (BuildContext context, int index){
                Opened();
                int now_num = widget.list[0]+index;
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: FloatingActionButton(
                    backgroundColor: opened[index]?Colors.blue:Colors.grey,
                    heroTag: 'button$index',
                    onPressed: opened[index]?(){
                      print('어떤 성경 : ${widget.title}');
                      print('줄임말 : ${widget.isBc?bc_char[result_num]:ad_char[result_num]}');
                      _goNextPage(context,now_num);
                    }:null,
                    child: CustomText('$now_num장', 15),
                  ),
                );
              }
          ),
        ),
      ),
    );
  }

  //장 버튼 활성화를 위해서 boolean을 list형태로 저장
  void Opened(){
    opened=[];
    if(widget.ui.whichCircle>widget.which_index){
      for(int k=min;k<max+1;k++){
        opened.add(true);
      }
    }
    else{
      for(int k=min;k<max+1;k++){
        if(k==min)
          opened.add(true);
        else if(widget.ui.inCircle+1>=k)
          opened.add(true);
        else
          opened.add(false);
      }
      }
  }

  //다음페이지로 가는 기능
  _goNextPage(BuildContext context, int now_num) async{
    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BiblePage(page: now_num, book: widget.title,
            char: widget.isBc?bc_char[result_num]:ad_char[result_num],isBc: widget.isBc,
            firstpage: min, lastpage: max, which_index : widget.which_index, ui: widget.ui)
    ));

    //아무 것도 반환되지 않는 경우는 그냥 pop만
    if(result!=null){
      setState(() {
        //reslult반환 받는 것을 전부다 inCircle로 넣고 버튼 새로고침
        widget.ui.inCircle=result;
        Opened();
      });
    }
  }

  // 구약, 신약 선택 후에 성경 선택 가능
  Widget buildBible(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isBc?'구약성경': '신약성경'),
      ),
      body: ListView.builder(
          itemCount: widget.isBc?bc.length:ad.length,
          itemBuilder: (BuildContext context, int index){
            return Container(
              height: size.height*0.08,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8)
              ),
              child: InkWell(
                splashColor: Colors.blueGrey,
                onTap: (){
                  widget.isBc?Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>SelectPage(
                        book: bc[index], book_char : bc_char[index],
                        max_page: bc_num[index], isBc: widget.isBc,)
                  ))
                      :Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>SelectPage(
                        book: ad[index], book_char : ad_char[index],
                        max_page: ad_num[index], isBc: widget.isBc,)
                  ));
                },
                child: Card(
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.isBc?CustomText(bc[index]+' (${bc_char[index]})', 16)
                          :CustomText(ad[index]+' (${ad_char[index]})', 16),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

// 성경이름 선택한 후에 몇 장을 볼건지 정해줌
class SelectPage extends StatelessWidget {

  final String book;
  final String book_char;
  final int max_page;
  final bool isBc;
  SelectPage({this.book, this.book_char, this.max_page, this.isBc});

  int max_page_num=0;
  static const int row_per_page=5;

  @override
  Widget build(BuildContext context) {

    //전체 장 수
    int page_num = max_page;
    // 줄 개수 확인
    int row_num = (page_num/row_per_page).toInt() +1;
    // 마지막 행 장수
    max_page_num = page_num%row_per_page;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(book),
      ),
      body: Container(
          width: size.width, height: size.height,
          child: ListView.builder(
              itemCount: row_num,
              itemBuilder: (BuildContext context, int index){

                if(index+1 == row_num){
                  return Column(
                    children: [
                      SizedBox(height: 5,),
                      LastRow(max_page_num, (index+1)*5, context),
                    ],
                  );
                }
                else
                  return Column(
                    children: [
                      SizedBox(height: 5,),
                      PageRow((index+1)*5, context),
                    ],
                  );
              })
      ),
    );
  }

  Widget PageRow(int page_cnt, BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SelectButton(page_cnt-4, context),
        SelectButton(page_cnt-3, context),
        SelectButton(page_cnt-2, context),
        SelectButton(page_cnt-1, context),
        SelectButton(page_cnt, context),
      ],
    );
  }

  Widget LastRow(int max_page_num, int page_cnt, BuildContext context){
    List<bool> last_row = [false,false,false,false,false];

    for(int i=0; i<max_page_num; i++){
      last_row[i] = true;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        last_row[0]?SelectButton(page_cnt-4, context):SizedBox(width: 80),
        last_row[1]?SelectButton(page_cnt-3, context):SizedBox(width: 80),
        last_row[2]?SelectButton(page_cnt-2, context):SizedBox(width: 80),
        last_row[3]?SelectButton(page_cnt-1, context):SizedBox(width: 80),
        last_row[4]?SelectButton(page_cnt, context):SizedBox(width: 80),
      ],
    );
  }

  Widget SelectButton(int page, BuildContext context){
    return InkWell(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context)
              // 추가로 전달해야 될 부분 첫페이지 마지막 페이지
              => BiblePage(book: book,char: book_char,page: page,isBc: isBc)
          ));
        },
        child: Container(
          color: Colors.yellow[200],
          width: 80, height: 40,
          child: Center(child: CustomText('$page', 25)),
        )
    );
  }
}




