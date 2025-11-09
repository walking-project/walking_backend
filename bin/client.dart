import 'dart:io';
import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';

Future main() async {
  var serverIp = InternetAddress.loopbackIPv4.host;
  var serverPort = 4040;
  var serverPath; // url 경로

  var httpClient = HttpClient();
  var httpResponseContent; // 응답으로 온 json

  HttpClientRequest httpRequest;
  HttpClientResponse httpResponse;

  print('<< userinfo CRUD >>');
  print("#1 회원가입 : POST userinfo");
  Map jsonContent = {
    'userid': 'lees8351', 
    'password': '1234', 
    'username': 'hello',
    };
  var content = jsonEncode(jsonContent); // 객체를 json 문자열로 반환
  serverPath = '/user';
  httpRequest = await httpClient.post(serverIp, serverPort, serverPath)
    ..headers.contentType = ContentType.json
    ..headers.contentLength = content.length // 본문(body) 타입과 길이 설정
    ..write(content); // http 요청 본문을 추가
  httpResponse = await httpRequest.close();
  print('회원 등록 완료');
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 3));

  print('#2 유저정보 조회: GET userinfo');
  serverPath = '/user/lees8351';
  httpRequest = await httpClient.get(serverIp, serverPort, serverPath);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 3));

  print('#3 유저정보 수정: PUT userinfo');
  jsonContent = {
    'userid': 'lees8351',
    'password': '1234',
    'username': 'world',
  };
  content = jsonEncode(jsonContent);
  serverPath = '/user/lees8351';
  httpRequest = await httpClient.put(serverIp, serverPort, serverPath)
    ..headers.contentType = ContentType.json
    ..headers.contentLength = content.length
    ..write(content);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 3));

  print('#4 유저정보 삭제: DELETE userinfo');
  serverPath = '/user/lees8351';
  httpRequest = await httpClient.delete(serverIp, serverPort, serverPath);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 3));

  print('<< pathinfo CRUD >>');
  print('#5 경로 저장: POST pathinfo');
  jsonContent = {
    'name': '집 앞 산책로',
    'point': [{'x': 0.0, 'y': 10.0}, {'x': 5.0, 'y': 26.0}, {'x': 15.0, 'y': 16.0}, {'x': 0.0, 'y': 10.0}],
    'description': '매일 아침 걷는 길',
    'distance': 55.3,
    'time': '30분',
  };
  content = jsonEncode(jsonContent);
  serverPath = '/path/lees8351';
  httpRequest = await httpClient.post(serverIp, serverPort, serverPath)
    ..headers.contentType = ContentType.json
    ..write(content);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 3));

  print('#6 경로 불러오기: GET pathinfo');
  serverPath = '/path/lees8351';
  httpRequest = await httpClient.get(serverIp, serverPort, serverPath);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 3));

  print('#7 경로 수정: PUT pathinfo');
  var prev = (jsonDecode(httpResponseContent) as List)[0] as Map;
  var pathId = prev['pathId'];
  var userid = prev['userid'];
  jsonContent = {
    'name': '공원',
    'point': [{'x': 0.0, 'y': 10.0}, {'x': 5.0, 'y': 26.0}, {'x': 15.0, 'y': 16.0}, {'x': 0.0, 'y': 10.0}],
    'description': '매일 아침 걷는 길',
    'distance': 55.3,
    'time': '30분',
    'pathId': pathId,
    'userid': userid,
  };
  content = jsonEncode(jsonContent);
  serverPath = '/path/lees8351/$pathId';
  httpRequest = await httpClient.put(serverIp, serverPort, serverPath)
    ..headers.contentType = ContentType.json
    ..write(content);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 3));

  print('#8 경로 삭제: DELETE pathinfo');
  serverPath = '/path/lees8351/$pathId';
  httpRequest = await httpClient.delete(serverIp, serverPort, serverPath);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 3));

  print('<< board CRUD >>');
  print('#9 게시판 글작성: POST board');
  jsonContent = {
    'title': '저희 집 주변 산책로를 소개합니다.',
    'content': '''녕끼어 실귀근은, 기데라쳔진은 애끼 젼시헤숴디사도 라느그꿔빈의, 여반혀우무를. 리겅눰 우남로오오게 오까여눅으냐 칙평가아게, 옹그렌아에 변던임웅다. 긋큡즈장벼 더핀띠다, 라어어 빤사인은 잔얼다 가체와 마저로, 옼핑그비의 맘츠는. 컹간썼초 만죠리아 업뙤러 넌고갚에 마날보호고다 개디가 리신오도 옹초다 어가의 캐잔시깃이, 숀저안. 베저아룅은 엔렙눟하가 시전믗사게, 그란메오가 지우타폰 후바서도 바기차리이토를 한언에. 버옴을 굴시거다 배라뱜근아 톅쭝탄인 응다다아가를 우어빌인의, 끨랭은 맇뭇의 아앝가본을. 탤독네가 갰젗누렝이는 치찬다로 사폾두우의 뇬오요. 

헤안다 땉끼닚젼의 그오고 어오래근가로 애가인조가 쫀히닣갬다. 무시에 너다익이 자이환친즈 주옴김앤는 제쿠다. 예센이 바기겐은 제얼상아 단사콘 깅뎐을, 갠녈검 오랐홋쳬, 재묵덴다 마와다. 벼어으싱 타니숸커라 나비빌의 낙기구의 몬스온을 모드에서 틸제니. 비매는 먈련눈으로 요사둠헤리는 빈소뗨 애데어하를 했아고바게, 나드자시의 하견가를 싱티를 긱지리의마를 효테히교할의. 만오이딜이다 인머전잣은 가추허로, 행운히이라 우눈이 운덩이 르엠븨 바귀게, 긴랜검개가. 룰디가 믑슥을 림쾨가 마님루다, 가읒져로 러좀 데그엔의. 거머랄잦으면 햐사가 놀티미살일 기떼 날아뷰액을 며암유다 배텨 믕선다. 

나사뿐 비기안오겄의 본뎌와 갆다던이니 앱으가겍을 하기체표다 싱노그냐. 롬인이 밴옸옹다앤 즈렴뤽사 틀망리쵸는 딜앟갑는다면 더아잉솜 고댄서새는. 제쌘이 됸며쌋는다 주헨, 새스터도 머보하버케팡과, 롬아이둣개 바딩뎔으로 거긘 안리옴으루는 죨팀안온 아윌졔대. 함소와 다바댤시라다 딘라김홰찬다 통밍여치라 나잴새머, 가매싰으나 갈겨가으가 엨어므시와, 겄수탄이. 증판습니다 으검어서 인가믕앵 신썅졸 옌공언은께 안노와 쿈리더교지요.''',
    'time': DateTime.now().toIso8601String(), // DateTime은 직접 인코딩이 안되어 수동으로 해줘야함 : toIso8601String()
    'likes': 20,
    'comment': [{
      'commentedUserId': 'suryeon1234',
      'commentContent': '우와 저도 가봐야겠어요',
    }],
  };
  content = jsonEncode(jsonContent);
  serverPath = '/board/lees8351';
  httpRequest = await httpClient.post(serverIp, serverPort, serverPath)
    ..headers.contentType = ContentType.json
    ..write(content);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 30));

  print('#10 게시판 글 불러오기: GET board');
  serverPath = '/board/lees8351';
  httpRequest = await httpClient.get(serverIp, serverPort, serverPath);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 3));

  print('#11 게시판 글 수정 : PUT board');
  prev = (jsonDecode(httpResponseContent) as List)[0] as Map;
  var postId = prev['postId'];
  userid = prev['userid'];
  serverPath = '/board/lees8351/$postId';
  jsonContent = {
    'title': '저희 집 주변 산책로를 소개합니다.',
    'content': '''년때팽벵은 따추현윙에 이퍈읍시다, 흐저자객식 르아가 시소선어 다겐깽. 랴안헐겔 샌호가 히료욱냅은 그액먼다 맀또가 즈하다 아쪈래라숱세의 어겸는 다바전캉이. 미죄는 개갔는, 룐레를 멘루져앙을 군추오흐로 버렌징솔바아요 서놉멘롬은 네암삽의.''',
    'time': DateTime.now().toIso8601String(), // DateTime은 직접 인코딩이 안되어 수동으로 해줘야함 : toIso8601String()
    'likes': 20,
    'comment': [{
      'commentedUserId': 'suryeon1234',
      'commentContent': '우와 저도 가봐야겠어요',
    }],
    'postId': postId,
    'userid': userid,
  };
  content = jsonEncode(jsonContent);
  httpRequest = await httpClient.put(serverIp, serverPort, serverPath)
    ..headers.contentType = ContentType.json
    ..write(content);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');

  sleep(Duration(seconds: 3));

  print('#12 게시판 글 삭제: DELETE board');
  serverPath = '/board/lees8351/$postId';
  httpRequest = await httpClient.delete(serverIp, serverPort, serverPath);
  httpResponse = await httpRequest.close();
  httpResponseContent = await utf8.decoder.bind(httpResponse).join();
  printHttpContentInfo(httpResponse, httpResponseContent);
  print('\n');
  
}

void printHttpContentInfo(var httpResponse, var httpResponseContent) {
  print('status code: ${httpResponse.statusCode}');
  print('content: ${httpResponseContent}');
}