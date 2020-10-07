import 'package:bible_app/style/textstyle.dart';
import 'package:bible_app/textReturn.dart';
import 'package:bible_app/userInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bible_app',
      home: TestUi(),
    );
  }
}



class TestUi extends StatelessWidget {
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

    print(ui.whichCircle);
    List<bool> isOpened = List<bool>();

    //각 버튼의 제목(어떤 성경인지)
    List<String> title = List<String>();
    title = ['빌립보서', '골로새서', '에베소서', '갈라디아서', '고린도전서',
    '이사야', '로마서', '사도행전', '요한복음', '요한계시록', '마태복음',
    '로마서'];
    //각 버튼마다 나타날 장 수
    List<List<int>> list = List<List<int>>();
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
        title: Text('UI 테스트'),
        centerTitle: true,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2
              ),
              itemCount: title.length,
              itemBuilder: (BuildContext context, int index){
                Size size = MediaQuery.of(context).size;
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        height: size.height,
                        width: size.width,
                        child: FloatingActionButton(
                          heroTag: 'button$index',
                          backgroundColor: isOpened[index]?Colors.primaries[index%18]:Colors.grey,
                          onPressed: isOpened[index] ?
                              (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context)
                                        => BibleList(isBc: false, title: title[index], list: list[index], ui: ui, which: index)
                                    )
                                );
                              }
                              :null,
                          elevation: 3,
                        ),
                      ),
                    ),
                    Positioned(
                      height: size.height*0.08,
                      width: size.width*0.5,
                      child: Container(
                          height: size.height,
                          width: size.width,
                          child: Center(child: CustomText('${title[index]}', 32))),
                    ),
                  ],
                );
              }
          ),
        ),
      ),
    );
  }
}

////기초 성경앱 시작부분
//class Main extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Center(
//      child: Scaffold(
//        appBar: AppBar(
//          title: Center(child: Text('성경 앱 테스트')),
//        ),
//        body: SelectTestament()
//      ),
//    );
//  }
//}
//
////구약, 신약 선택
//class SelectTestament extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    Size size = MediaQuery.of(context).size;
//    return Container(
//      color: Colors.yellow[50],
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.end,
//        children: [
//          Row(
//            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            children: [
//              FlatButton(
//                shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(20)
//                ),
//                onPressed: (){
//                  Navigator.of(context).push(MaterialPageRoute(
//                    builder: (context) => BibleList(isBc: true)
//                  ));
//                },
//                color: Colors.brown[200],
//                child: Container(
//                  height: size.height*0.2,
//                  width: size.width*0.3,
//                  child: Center(
//                    child: CustomText('구약성경', 25),
//                  ),
//                ),
//              ),
//              FlatButton(
//                shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(20)
//                ),
//                onPressed: (){
//                  Navigator.of(context).push(MaterialPageRoute(
//                      builder: (context) => BibleList(isBc: false)
//                  ));
//                },
//                color: Colors.brown[200],
//                child: Container(
//                  height: size.height*0.2,
//                  width: size.width*0.3,
//                  child: Center(
//                    child: CustomText('신약성경', 25),
//                  ),
//                ),
//              ),
//            ],
//          ),
//          SizedBox(height: size.height*0.2)
//        ],
//      ),
//    );
//  }
//}


class BibleList extends StatefulWidget {

  bool isBc;
  List<int> list;
  String title;
  UserInfo ui;
  int which;
  BibleList({this.isBc, this.list, this.title, this.ui, this.which});


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

  // 범위에 맞는 성경 장수만 버튼형태로 출력
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    print('BibleList : ${widget.ui.whichCircle}');

    min = widget.list[0];
    max = widget.list[0]+widget.list[1]-1;

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
                int now_num = widget.list[0]+index;
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: FloatingActionButton(
                    heroTag: 'button$index',
                    onPressed: (){
                      print('페이지 : $now_num');
                      print('어떤 성경 : ${widget.title}');
                      print('줄임말 : ${widget.isBc?bc_char[result_num]:ad_char[result_num]}');
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => BiblePage(page: now_num, book: widget.title,
                            char: widget.isBc?bc_char[result_num]:ad_char[result_num],isBc: widget.isBc,
                            firstpage: min, lastpage: max, which : widget.which, ui: widget.ui)
                      ));
                    },
                    child: CustomText('$now_num장', 15),
                  ),
                );
              }
          ),
        ),
      ),
    );
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




