import 'dart:io';
import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';

Future main() async { // Future는 promise에 대응, 비동기 처리를 위한 것
  var db = await Db.create("mongodb+srv://lees8351:suryeon1121@cluster0.wqukfws.mongodb.net/user?appName=Cluster0");
  await db.open();
  print('DB is open');

  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    4040,
  );

  Future<void> createDB(var collection, var data, var field, [var id]) async {
      if(field == 'posting') {
        data['postId'] = ObjectId();
        data['userid'] = id;
        data['time'] = DateTime.parse(data['time']); // DateTime 직접 디코딩 필요
      }
      else if(field == 'path') {
        data['pathId'] = ObjectId();
        data['userid'] = id;
      }
      else {
        data['_id'] = ObjectId();
      }
      await collection.insertOne(data);
      print('All items in userinfo: ${await db.collection('userinfo').find().toList()}');
      print('All items in pathinfo: ${await db.collection('pathinfo').find().toList()}');
      print('All items in board: ${await db.collection('board').find().toList()}');
      print('Data inserted: $data');
      print('\n');
  }

  Future<List<Object>> readDB(var collection, var id, [var field]) async {
    var result = await collection.find(where.eq('userid', id)).toList();
    print('Data found: $result');
    if(field == 'posting') {
      for(var r in result) {
        r['time'] = r['time'].toIso8601String();
      }
    };
    print('\n');
    return result;
  }

  Future<void> updateDB(var collection, var uri, var data, var field) async {
    var result;
    if(field == 'path') {
      data['pathId'] = ObjectId.fromHexString(data['pathId']);
      await collection.updateOne(where.eq('pathId', ObjectId.fromHexString(uri[2])),
        {
          r'$set': data,
        }
      );
      result = await collection.findOne(where.eq('pathId', ObjectId.fromHexString(uri[2])));
    }
    else if(field == 'posting') {
      data['time'] = DateTime.parse(data['time']);
      data['postId'] = ObjectId.fromHexString(data['postId']);
      await collection.updateOne(where.eq('postId', ObjectId.fromHexString(uri[2])),
        {
          r'$set': data,
        }
      );
      result = await collection.findOne(where.eq('postId', ObjectId.fromHexString(uri[2])));
    }
    else {
      await collection.updateOne(where.eq('userid', uri[1]),
        {
          r'$set': data,
        }
      );
      result = await collection.findOne(where.eq('userid', uri[1]));
    }
    print('Data updated: $result');
    print('\n');
  }

  Future<Object> deleteDB(var collection, var uri, var field) async {
    var data;
    if(field == 'path') {
      data = await collection.findOne(where.eq('pathId', ObjectId.fromHexString(uri[2])));
      await collection.deleteOne({'pathId': ObjectId.fromHexString(uri[2])});
    }
    else if(field == 'posting') {
      data = await collection.findOne(where.eq('postId', ObjectId.fromHexString(uri[2])));
      await collection.deleteOne({'postId': ObjectId.fromHexString(uri[2])});
    }
    else {
      data = await collection.findOne(where.eq('userid', uri[1]));
      await collection.deleteOne({'userid': uri[1]});
    }
    print('Data deleted: $data');
    print('\n');
    return data;
  }

  void requestHandler(var collection, var method, HttpRequest request, var field) async {
      final uri = request.uri.pathSegments;
      switch(method) {
        case 'POST':
          var content = await utf8.decoder.bind(request).join();
          var data = jsonDecode(content) as Map;
          if(uri.length >= 2) {
            var id = uri[1];
            await createDB(collection, data, field, id);
          }
          else {
            await createDB(collection, data, field);
          }
          content = '$data is accepted';
          request.response
            ..headers.contentType = ContentType('text', 'plain', charset:'utf-8')
            ..headers.contentLength = utf8.encode(content).length
            ..statusCode = HttpStatus.ok
            ..write(content);
          await request.response.close();
          break;
        case 'GET':
          var id = uri[1];
          var data;
          if(field == 'posting') data = jsonEncode(await readDB(collection, id, field));
          else data = jsonEncode(await readDB(collection, id));
          request.response
            ..headers.contentType = ContentType('text', 'plain', charset:'utf-8')
            ..headers.contentLength = utf8.encode(data).length
            ..statusCode = HttpStatus.ok
            ..write(data);
          await request.response.close();
          break;
        case 'PUT':
          var content = await utf8.decoder.bind(request).join();
          var data = jsonDecode(content) as Map;
          await updateDB(collection, uri, data, field);
          content = '$data is updated';
          request.response
            ..headers.contentType = ContentType('text', 'plain', charset:'utf-8')
            ..headers.contentLength = utf8.encode(content).length
            ..statusCode = HttpStatus.ok
            ..write(content);
          await request.response.close();
          break;
        case 'DELETE':
          var data = await deleteDB(collection, uri, field);
          var content = '$data is deleted';
          request.response
            ..headers.contentType = ContentType('text', 'plain', charset: 'utf-8')
            ..headers.contentLength = utf8.encode(content).length
            ..statusCode = HttpStatus.ok
            ..write(content);
          await request.response.close();
          break;
        default:
          print('Unsupported http method');
      }
  }

  await for(HttpRequest request in server) {
    try {
      var method = request.method;

      if(request.uri.path == '/') {
        // main page
      }
      else if(request.uri.path.contains('/user')) {
        var users = db.collection('userinfo');
        requestHandler(users, method, request, 'user');
      }
      else if(request.uri.path.contains('/path')) {
        var paths = db.collection('pathinfo');
        requestHandler(paths, method, request, 'path');
      }
      else if(request.uri.path.contains('/board')) {
        var boards = db.collection('board');
        requestHandler(boards, method, request, 'posting');
      }
      else {
        print('Unsupported API');
      }
    } catch(err) {
      print('Error: $err');
    }
  }

}