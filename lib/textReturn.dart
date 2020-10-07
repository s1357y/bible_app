import 'package:bible_app/style/textstyle.dart';
import 'package:bible_app/userInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiblePage extends StatefulWidget {

  final String book;
  final String char;
  int page;
  final bool isBc;
  final int firstpage;
  final int lastpage;
  final UserInfo ui;
  final int which;

  BiblePage({this.book,this.char, this.page, this.isBc
    , this.firstpage, this.lastpage, this.ui, this.which});

  @override
  _BiblePageState createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {

  // ???왜 해놨는지 모르겠음 필요없으면 지워도 될듯
  bool iserror = false;
  Size size;

  @override
  Widget build(BuildContext context) {

    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomText('${widget.book} ${widget.page}장', 25),
      ),
      body: ShowBible(widget.char,widget.page),
//      bottomSheet: BottomAppBar(
//        elevation: 10,
//        child: Container(
//          height: size.height*0.05,
//          child: Center(
//            child: CustomText('text', 15),
//          ),
//        ),
//      ),
    );
  }

  //해당 성경을 보여줌 -> ShowBc 나 ShowAd로 넘어감
  Widget ShowBible(String char, int i){
    return widget.isBc?ShowBc('$char$i.txt')
        :ShowAd('$char$i.txt');
  }

  // BC인지 AD인지에 따라 각각에 맞춰서 ShowEachPage로 넘어감
  Widget ShowBc(String page){
    String addBc = 'bc/$page';
    return ShowEachPage(addBc);
  }

  Widget ShowAd(String page){
    String addAd = 'ad/$page';
    return ShowEachPage(addAd);
  }

  // 해당 장 화면에 ListView형태로 출력
  Widget ShowEachPage(String page){
    return FutureBuilder(
      // 해당절을 텍스트 파일에서 불러옴
        future: loadString('assets/$page'),
        builder: (context,snapshot) {
          final contents = snapshot.data.toString();

          //절 마다 나눠서 저장
          final rows = contents.split('\n');
          List<String> jul = List<String>();
          jul = rows;

          if(jul.isEmpty){
            setState(() {
              iserror = true;
            });
          }

          // 현재 페이지를 page변수에 저장 나중에 setstate 페이지 변경에 쓰임
          int page = widget.page;

          //성경 각 구절 출력
          return ListView.builder(
              itemCount: jul.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                if(index==jul.length-1){
                  return Container(
                    height: size.height*0.05,
                    child: Row(
                      children: [
                        (widget.page==widget.firstpage)
                            ?IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              showLog('첫 페이지 입니다');
                            })
                            : IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              setState(() {
                                widget.page = page-1;
                              });
                            }),
                        Expanded(child: SizedBox()),
                          (widget.page == widget.lastpage)
                            ? IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () {
                                  widget.ui.whichCircle>widget.which?
                                      showLog('이미 읽은 성경 입니다'
                                          '\n이전 페이지로 돌아갑니다')
                                      : showLog('마지막 페이지입니다. '
                                          '\n\n ${widget.book}을 다 읽으셨습니까?'
                                          '\n 예를 누르면 다음 성경을 읽을 수 있습니다.');
                                },
                              )
                            : IconButton(
                                icon: Icon(Icons.arrow_forward_ios),
                                onPressed: () {
                                  setState(() {
                                    widget.page = page+1;
                                  });
                                }),
                      ],
                    ),
                  );
                } else{
                  return Container(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal : 8.0),
                          child: Text('${jul[index]}',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        ),
                      ));
                }
              }
          );
        }
    );
  }

  void showLog(String content){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            content: Text(content),
            // 마지막 페이지 일 경우에만 선택 생성
            actions: content=='마지막 페이지입니다. '
                '\n\n ${widget.book}을 다 읽으셨습니까?'
                '\n 예를 누르면 다음 성경을 읽을 수 있습니다.'

                ?NotYet()
                :content=='이미 읽은 성경 입니다'
                '\n이전 페이지로 돌아갑니다'

                ?Already()
                :null,
          );
        }
    );
  }

  //아직 안읽은 성경인 경우
  List<Widget> NotYet(){
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(child: CustomText('예', 15),
            onTap: (){
              if(widget.ui.whichCircle>widget.which){}
              FirebaseFirestore.instance.collection('user').doc('user0').update({'whichcircle' : widget.ui.whichCircle+1});
              Navigator.pop(context);
              Navigator.pop(context);
            }),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(child: CustomText('아니오', 15),
            onTap: (){
              Navigator.pop(context);
            }),
      ),
    ];
  }

  // 이미 읽은 성경인 경우
  List<Widget> Already(){
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(child: CustomText('예', 15),
            onTap: (){
              Navigator.pop(context);
              Navigator.pop(context);
            }),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(child: CustomText('아니오', 15),
            onTap: (){
              Navigator.pop(context);
            }),
      ),
    ];
  }

  // 텍스트 파일을 경로에 맞게 불러오는 역할
  Future<String> loadString(String path)async{
    return await rootBundle.loadString(path);
  }
}