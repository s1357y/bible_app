import 'package:bible_app/style/textstyle.dart';
import 'package:bible_app/userInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiblePage extends StatefulWidget {

  final String book;
  final String char;
  final bool isBc;
  final int firstpage;
  final int lastpage;
  final UserInfo ui;
  final int which_index;
  int page;

  BiblePage({this.page, this.book,this.char, this.isBc
    , this.firstpage, this.lastpage, this.ui, this.which_index});

  @override
  _BiblePageState createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  
  Size size;
  int finalread;

  @override
  Widget build(BuildContext context) {

    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading:IconButton(
          onPressed: (){
            Navigator.of(context).pop(widget.ui.inCircle);
            },
          icon: Icon(Icons.backspace),
        ),
        centerTitle: true,
        title: CustomText('${widget.book} ${widget.page}장', 25),
      ),
      body: WillPopScope(
          child: ShowBible(widget.char,widget.page),
        onWillPop: (){
            Navigator.of(context).pop(widget.ui.inCircle);
            return null;
        },
      ),
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
    return widget.isBc?ShowBc('$char$i.txt', i)
        :ShowAd('$char$i.txt', i);
  }

  // BC인지 AD인지에 따라 각각에 맞춰서 ShowEachPage로 넘어감
  Widget ShowBc(String page, int i){
    String addBc = 'bc/$page';
    return ShowEachPage(addBc, i);
  }

  Widget ShowAd(String page, int i){
    String addAd = 'ad/$page';
    return ShowEachPage(addAd, i);
  }

  // showpage가 진짜 실제로 불러오는 페이지 == widget.page
  // 해당 장 화면에 ListView형태로 출력
  Widget ShowEachPage(String page, int showpage){
    return FutureBuilder(
      // 해당절을 텍스트 파일에서 불러옴
        future: loadString('assets/$page'),
        builder: (context,snapshot) {
          final contents = snapshot.data.toString();

          //절 마다 나눠서 저장
          final rows = contents.split('\n');
          List<String> jul = List<String>();
          jul = rows;

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
                                widget.page = showpage-1;
                              });
                            }),
                        Expanded(child: SizedBox()),
                          //해당 성경 끝(마지막 장)
                          (widget.page == widget.lastpage)
                            ? IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () {
                                  //firestore에 저장된 부분이 더 클경우(이미 읽은 부분)
                                  if(widget.ui.whichCircle>widget.which_index)
                                    showLog('이미 읽은 성경 입니다'
                                        '\n이전 페이지로 돌아갑니다');
                                  //처음으로 온 부분일 경우 다음 성경 오픈
                                  else
                                     showLog('마지막 페이지입니다. '
                                          '\n\n ${widget.book}을 다 읽으셨습니까?'
                                          '\n 예를 누르면 다음 성경이 오픈됩니다.');
                                },
                              )
                            //마지막 장이 아닐 경우(다음 페이지)
                            : IconButton(
                                icon: Icon(Icons.arrow_forward_ios),
                                onPressed: () {
                                    // 현재가 저장된 마지막 성경일 경우
                                    if(widget.ui.whichCircle==widget.which_index){
                                      // firestore에 저장된 장이 현재 페이지보다 작거나 같을 경우
                                      // inCircle에 +1해서 더해주기 위함
                                      if(widget.ui.inCircle<=showpage){
                                        showLog('현재 페이지를 다 읽었습니까?'
                                            '\n예를 누르면 다음 장으로 넘어갑니다.');
                                      }
                                      // firestore에 저장된 장이 현재 페이지보다 클 경우(이미 지나간 장장)
                                       else{
                                        setState(() {
                                          widget.page = showpage+1;
                                        });
                                      }
                                    }
                                    // 이미 지나간 성경일 경우에 그냥 패스
                                    else if(widget.ui.whichCircle>widget.which_index){
                                      setState(() {
                                        widget.page = showpage+1;
                                      });
                                    }
                                    else{
                                      SnackBar(content: Text('잘못된 진행입니다.'));
                                    }
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
                '\n 예를 누르면 다음 성경이 오픈됩니다.'
                ?NotYet()
                :content=='이미 읽은 성경 입니다'
                '\n이전 페이지로 돌아갑니다'

                ?Already()
                :content=='현재 페이지를 다 읽었습니까?'
                '\n예를 누르면 다음 장으로 넘어갑니다.'

                ?NextPage()
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
              FirebaseFirestore.instance.collection('user').doc('user0')
                  .update({'whichcircle' : widget.ui.whichCircle+1, 'incircle' : 0});
              //팝업 닫기
              Navigator.pop(context);
              //이전페이지로 돌아가기
              Navigator.of(context).pop(widget.ui.inCircle);
            }),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(child: CustomText('아니오', 15),
            onTap: (){
              //팝업닫기
              Navigator.pop(context);
            }),
      ),
    ];
  }

  //페이지 넘김
  List<Widget> NextPage(){
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(child: CustomText('예', 15),
            onTap: (){
              setState(() {
                //현재 페이지를 다음페이지로 이동
                widget.page =widget.page+1;
                // 반환할 값을 1추가
                widget.ui.inCircle = widget.page-1;
              });
              //incircle값을 추가해서 데이터베이스에 저장
              // 공개할 페이지 넘버 증가
                FirebaseFirestore.instance.collection('user').doc('user0')
                    .update({'incircle' : widget.ui.inCircle});
                //팝업창만 닫기
              Navigator.of(context).pop();
            }
            ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(child: CustomText('아니오', 15),
            onTap: (){
            //팝업창만 닫기
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
              //팝업창 닫기
              Navigator.pop(context);
              //이전 페이지로 돌아가기
              Navigator.of(context).pop(widget.ui.inCircle);
            }),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(child: CustomText('아니오', 15),
            onTap: (){
              //팝업닫기
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