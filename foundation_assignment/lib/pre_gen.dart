import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:recase/recase.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:uuid/uuid.dart';

Future<void> main(List<String> arguments) async {
  try {
    var data;
    Postman? postman;
    //  while (true) {
    final linkPath =
        'https://staging-api.arora.earth/v2/api-docs?group=1.%20User%20APIs';
    final message = linkValidation(linkPath);
    if (message != null) {
      print(message.toString());
    } else {
      data = await getSwaggerJson(linkPath);
      print('swaggerData:::::::::::::::::::::::::$data');
      postman = getPostmanModel(data);
      //print('responseOfPostman::::::::::::::::::::::$postman');
      if (postman == null) {
        print('your swagger response is null.');
      } else {
        // break;
      }
    }
    // }

    print('Generating your apis....');
    // list of feature
    List<dynamic> finalFeatureList = [];
    //list of errors
    List<String> errorListForJson = [];
    // {'method_name':  model_name}
    Map<String, dynamic> methodReturnModel = {};
    // {'method_name':  model_name}
    Map<String, dynamic> methodRequestModel = {};
    //json map
    Map<String, dynamic> jsonMap = {};
    //json map for request
    Map<String, dynamic> jsonMapRequest = {};
    //one feature common map {"feature_name": ["get1","get2"]}
    Map<String, List<String>> featureModelMap = {};
//  Map<String, List<String>> featureModelMapOther = {};
    //final model map
    // Map<String,dynamic> modelMap = {};
    //final headers
    List<HeaderList> finalHeaders = [];

    //global variable
    Set globalVariable = {};

    List<PostmanItem?> featureList = [];
    print('postman.item :::::::::::::::::::::${List.from(postman!.item ?? [])}');
    featureList = List.from(postman.item!);
    addJsonDataForAllMethods(featureList, errorListForJson, jsonMap,
        jsonMapRequest, methodReturnModel, methodRequestModel);
    featureModelMap = await setModel(jsonMap);

    if (errorListForJson.isEmpty) {
      features(featureList, finalHeaders, globalVariable, finalFeatureList,
          featureModelMap, jsonMap, methodReturnModel, methodRequestModel);
    } else {
      print('${errorListForJson.join('\n').toString()}');
      print(
          'total : ${errorListForJson.length.toString()} Errors you want to fix....');
    }
  } catch (e, s) {
    print('Error-> ${e.toString()}');
    print('ListStackTrace-> ${format(s).toString()}');
    //print('postStackTrace::::::::::::::${s.toString()}');
    return null;
  }
}

Postman? getPostmanModel(data) {
  try {
    var dataTypes = {
      'string': 'String',
      'number': 0.0,
      'integer': 0,
      'double': 0.0,
      'boolean': false
    };
    //'dynamic'
    //'DateTime'

    var uuid = Uuid();
    // var abc = data.entries.toList().last;
    // print(abc.key);
    List<PostmanItem?> featureList = [];
    List<Map<String, dynamic>> tags = List.from(data['tags']);
    Map<String, dynamic> securityDefinitions = data['securityDefinitions'];
    Header? headerAuth;
    for (var def in securityDefinitions.entries) {
      if (def.value['type'].toString() == 'apiKey') {
        headerAuth = Header(
            key: def.value['name'].toString(),
            value: 'Bearer {{authorization-token}}',
            description: 'securityDefinitions',
            type: def.value['type'].toString(),
            disabled: false,
            src: '');
        break;
      }
    }
    //add features
    for (var element in tags) {
      featureList.add(PostmanItem(
          name: element['name'].toString(), item: [], id: uuid.v4()));
    }

    Map<String, dynamic> paths = data['paths'];

    paths.forEach((key1, value1) {
      Map<String, dynamic> methodTypeMap = value1;
      methodTypeMap.forEach((key2, value2) {
        String methodType = key2;
        dynamic url;
        Map<String, dynamic> method = value2;
        List<String> featureNames = List.from(method['tags']);

        List<Parameters> parameters = method['parameters'] == null
            ? []
            : List.from(
            method['parameters'].map((x) => Parameters.fromJson(x)));
        List<Header> headerList = [];
        List<Parameters> queryParams =
        List.from(parameters.where((element) => element.ins == 'query'));
        List<Parameters> headerParams =
        List.from(parameters.where((element) => element.ins == 'header'));
        List<Parameters> bodyParams =
        List.from(parameters.where((element) => element.ins == 'body'));
        List<Parameters> formDataParams =
        List.from(parameters.where((element) => element.ins == 'formData'));

        if (queryParams.isEmpty) {
          url = key1.toString();
        } else {
          List<Query> queries = [];
          for (var element in queryParams) {
            queries.add(Query(key: element.name, value: element.name));
          }
          UrlClass urlClass = UrlClass(
              raw: key1.toString(),
              protocol: '',
              host: [''],
              path: key1.toString().split('/'),
              query: queries);
          url = urlClass;
        }

        if (bodyParams.isNotEmpty) {
          headerList.add(Header(
              key: 'Content-Type',
              value: 'application/json',
              description: '',
              type: 'text',
              disabled: false,
              src: ''));
        }
        if (formDataParams.isNotEmpty && method['consumes'].first != null) {
          headerList.add(Header(
              key: 'Content-Type',
              value: method['consumes'].first.toString(),
              description: '',
              type: 'text',
              disabled: false,
              src: ''));
        }
        for (var header in headerParams) {
          if (header.type.toString() == 'apiKey') {
            headerList.add(Header(
                key: header.name.toString(),
                value: 'Bearer {{authorization-token}}',
                description: 'securityDefinitions',
                type: header.type.toString(),
                disabled: false,
                src: ''));
          }
          headerList.add(Header(
              key: header.name ?? '',
              value: '{{${header.name ?? ''}}}',
              description: header.description ?? '',
              type: header.type ?? '',
              disabled: header.required ?? false,
              src: ''));
        }
        Body? body;
        headerAuth != null ? headerList.add(headerAuth) : null;
        if (bodyParams.isNotEmpty) {
          Map<String, dynamic> currentMap = {};
          dynamic finalMap;
          if (bodyParams[0].schema != null) {
            Schema schema = bodyParams[0].schema!;
            if (schema.ref != null) {
              currentMap = getMap(schema.ref ?? '', data);
              finalMap = recursiveCall(currentMap, dataTypes, data);
            } else if (schema.type != null && schema.items != null) {
              currentMap = getMap(schema.items!.ref ?? '', data);
              finalMap = [recursiveCall(currentMap, dataTypes, data)];
            }
            //  schema.type
          } else {
            //   print('finalMap -> no data');
            // no data
          }
          body = Body(mode: 'raw', formdata: null, raw: json.encode(finalMap));
        } else if (formDataParams.isNotEmpty) {
          List<Header> formData = [];
          for (var form in formDataParams) {
            formData.add(Header(
                key: form.name ?? '',
                value: form.name ?? '',
                description: form.description ?? '',
                type: form.type ?? '',
                disabled: form.required != null ? !form.required! : false,
                src: []));
            print('fromData:::::::::::::::::::::$form');
          }
          body = Body(mode: 'formdata', formdata: formData, raw: null);
        }
        Request request = Request(
            method: methodType.toString().toUpperCase(),
            header: headerList,
            body: body,
            url: url,
            auth: null,
            description: null);
        print('request::::::::::::::::::::::$request');

        //responses
        List<PostmanResponse> postmanResponses = [];
        Map<String, dynamic> responses = method['responses'];
        if (responses.isNotEmpty) {
          print('summary->${method['summary']}');
          print('response::::::::::::::::$responses');
          responses.forEach((key, value) {
            //key = code
            Map<String, dynamic> currentMap = {};
            dynamic finalMap;
            Parameters parameters = Parameters.fromJson(value);
            if (parameters.schema?.ref != null &&
                parameters.schema!.ref!.isNotEmpty) {
              currentMap = getMap(parameters.schema!.ref ?? '', data);
              finalMap = recursiveCall(currentMap, dataTypes, data);
              print('finalMap -> ${json.encode(finalMap)}');
            } else if (parameters.schema?.type != null &&
                parameters.schema?.items != null) {
              currentMap = getMap(parameters.schema!.items!.ref ?? '', data);
              finalMap = [recursiveCall(currentMap, dataTypes, data)];
              print('finalMap -> ${json.encode(finalMap)}');
            } else {
              // for dataTypes
            }
            postmanResponses.add(PostmanResponse(
                name: parameters.schema?.desc ?? '',
                code: int.parse(key.toString()),
                status: parameters.schema?.desc ?? '',
                body: finalMap == null ? null : json.encode(finalMap ?? {}),
                header: [],
                id: uuid.v4()));
          });
        }

        //method
        ItemItem itemItem = ItemItem(
            name: method['summary'].toString(),
            id: uuid.v4(),
            request: request,
            response: postmanResponses,
            event: null);

        featureList.asMap().forEach((key, value) {
          if (featureNames.contains(value?.name ?? '')) {
            List<ItemItem?> itemMethod = featureList[key]?.item ?? [];
            itemMethod.add(itemItem);
            featureList[key]?.copyWith(item: itemMethod);
          }
        });
      });
    });
    //postman!.copyWith(info: null, item: featureList);
    Postman postman = Postman(info: null, item: List.from(featureList));
    print('postman::::::::::::::::::${postman.item}');
    return postman;
  } catch (e, s) {
    print('Error-> ${e.toString()}');
    print('StackTrace-> ${format(s).toString()}');
    //print('postStackTrace::::::::::::::${s.toString()}');
    return null;
  }
}

String? linkValidation(String modelPath) {
  if (modelPath.isEmpty) {
    return 'swagger link is empty.';
  } else {
    if (!Uri.parse(modelPath).isAbsolute
    //||
    //  !modelPath.contains('www.getpostman.com/collections')
    ) {
      return 'please enter valid swagger link.';
    }
  }
  return null;
}

void features(
    List<PostmanItem?> featureList,
    List<HeaderList> finalHeaders,
    Set globalVariable,
    List finalFeatureList,
    featureModelMap,
    Map<String, dynamic> jsonMap,
    Map<String, dynamic> methodReturnModel,
    Map<String, dynamic> methodRequestModel) {
  try {
    for (var feature in featureList) {
      List<dynamic> getMethods = [];
      List<dynamic> postMethods = [];
      List<dynamic> putMethods = [];
      List<dynamic> deleteMethods = [];
      List<ItemItem?> methodList = feature?.item ?? [];

      List<dynamic> repo1 =
      setListOfModels(featureModelMap, feature!.name.toString().snakeCase);
      // List<dynamic> repo2 = setListOfModels(
      //     featureModelMapOther, feature.name.toString().snakeCase);
      if (methodList.isNotEmpty) {
        for (var method in methodList) {
          if (method != null) {
            if (method.request != null) {
              commonMethodCall(
                  getList(method.request!.method.toString(), getMethods,
                      postMethods, putMethods, deleteMethods),
                  method,
                  finalHeaders,
                  feature.name.toString(),
                  featureModelMap,
                  jsonMap,
                  methodReturnModel,
                  methodRequestModel);
            } else {
              //add to error list
            }
          }
        }
      } else {
        //add to error list
      }
      print('finalFeatureList:::::::::::::::$repo1');
      finalFeatureList.add({
        'repo1': repo1,
        //'models': featureModelMap[feature.name.camelCase.toString()],
        'feature_name': feature.name.toString().snakeCase,
        'getMethods': getMethods,
        'postMethods': postMethods,
        //  'putMethods': putMethods,
        'deleteMethods': deleteMethods,
      });
    }

    for (var header in finalHeaders) {
      for (var item in header.headerList) {
        //var item2 = item;
        var index = header.headerList.indexOf(item);
        item = item.copyWith(
            value: replaceBracketWithDollar(
                item.value.toString(), RegExp('\\{{(.*?)\\}}')));
        if ((item.value?.contains('\$')) ?? false) {
          globalVariable.add(item.value
              .toString()
              .split('\$')
              .last
              .toString()
              .trim()
              .replaceAll(RegExp(r'[{}]'), ''));
        }
        header.headerList[index] = item;
      }
    }
    // context.vars = {
    //   ...context.vars,
    //   'isBloc': true,
    //   'isCubit': false,
    //   'finalFeatureList': finalFeatureList,
    //   'finalHeaders': finalHeaders,
    //   'globalVariable': globalVariable.toList()
    // };
  } catch (e, stackTrace) {
    print('Error:-> \n Something went wrong... ');
    print(format(stackTrace));
  }
}

List getList(String method, List getMethods, List postMethods, List putMethods,
    List deleteMethods) {
  switch (method) {
    case 'GET':
      return getMethods;
    case 'POST':
      return postMethods;
    case 'PUT':
      return postMethods;
    case 'DELETE':
      return deleteMethods;
    default:
      return getMethods;
  }
}

void addJsonDataForAllMethods(
    List<PostmanItem?>? featureList,
    List<String> errorListForJson,
    Map<String, dynamic> jsonMap,
    Map<String, dynamic> jsonMapRequest,
    Map<String, dynamic> methodReturnModel,
    Map<String, dynamic> methodRequestModel) {
  String errorHandle = '';
  if (featureList != null) {
    for (var feature in featureList) {
      List<AddJson> methodListReturnModelNameForAll = [];
      // List<AddJson> methodListRequestModelNameForAll = [];
      // List<dynamic> methodListFormData = [];
      var dataTypes = <String>[
        'String',
        'num',
        'int',
        'double',
        'bool',
        'dynamic',
        'DateTime'
      ];
      var count11 = 0;
      //  var count22 = 0;
      for (var method in feature?.item ?? []) {
        //Add  Common Error Handling model
        if (method.request != null) {
          bool isGet = method.request!.method == 'GET';
          // if (method.request!.method == "GET") {
          if (method.response.isEmpty) {
            //add to error list

            if (isGet) {
              errorListForJson.add('featureName : ${feature?.name}'
                  ', methodName : ${method.name}, Error : method response is empty.');
            } else {
              //  {set return type dynamic for others}
              methodReturnModel[method.name.toString().snakeCase] = 'dynamic';
            }
          } else {
            if (method.response[0]!.body.toString().isEmpty) {
              //add to error list
              if (isGet) {
                errorListForJson.add('featureName : ${feature?.name}'
                    ', methodName : ${method.name}, Error : method response body is empty.');
              } else {
                //  {set return type dynamic for others}
                methodReturnModel[method.name.toString().snakeCase] = 'dynamic';
              }
            } else {
              var differance =
              methodListReturnModelNameForAll.firstWhereOrNull((element) {
                List<Map<int, dynamic>> myList1 = [];
                List<Map<int, dynamic>> myList2 = [];
                int count1 = 0;
                int count2 = 0;
                newClassFunction(
                    json.decode(element.body), dataTypes, count1, myList1);
                newClassFunction(
                    json.decode(method.response[0]!.body.toString()),
                    dataTypes,
                    count2,
                    myList2);
                return areListsEqual(myList1, myList2);
              });

              //differance == null
              if (differance == null) {
                count11++;

                methodReturnModel[method.name.toString().snakeCase] =
                '${feature?.name}$count11';
                methodListReturnModelNameForAll.add(AddJson(
                    body: method.response[0]!.body.toString(),
                    modelName: '${feature?.name}$count11'));
              } else {
                methodReturnModel[method.name.toString().snakeCase] =
                '${feature?.name}$count11';
              }
            }
          }
          //   }
          if (method.request?.body != null) {
            if (method.request!.body!.mode == "raw") {
              if (method.request!.body!.raw.isNotEmpty) {
                var differance =
                methodListReturnModelNameForAll.firstWhereOrNull((element) {
                  List<Map<int, dynamic>> myList1 = [];
                  List<Map<int, dynamic>> myList2 = [];
                  int count1 = 0;
                  int count2 = 0;
                  newClassFunction(
                      json.decode(element.body), dataTypes, count1, myList1);
                  newClassFunction(
                      json.decode(method.request!.body!.raw.toString()),
                      dataTypes,
                      count2,
                      myList2);
                  return areListsEqual(myList1, myList2);
                });

                //differance == null
                if (differance == null) {
                  count11++;

                  methodRequestModel[method.name.toString().snakeCase] =
                  '${feature?.name}$count11';
                  methodListReturnModelNameForAll.add(AddJson(
                      body: method.request!.body!.raw.toString(),
                      modelName: '${feature?.name}$count11'));
                } else {
                  methodRequestModel[method.name.toString().snakeCase] =
                  '${feature?.name}$count11';
                }
              }
            } else {
              //form data
              Map<String, dynamic> formDataMap = {};
              List<Header> formDataList =
              method.request!.body?.formdata as List<Header>;

              if (formDataList.isNotEmpty) {
                List<Header> formDataList =
                method.request!.body!.formdata as List<Header>;
                formDataList.forEach((element) {
                  if (element.type == 'file') {
                    if (element.src != null) {
                      formDataMap[element.key.toString()] = [
                        {"file_name": "string", "file_path": "string"}
                      ];
                    }
                  } else {
                    formDataMap[element.key.toString()] = "string";
                  }
                });

                var differance =
                methodListReturnModelNameForAll.firstWhereOrNull((element) {
                  List<Map<int, dynamic>> myList1 = [];
                  List<Map<int, dynamic>> myList2 = [];
                  int count1 = 0;
                  int count2 = 0;
                  newClassFunction(
                      jsonDecode(element.body), dataTypes, count1, myList1);
                  newClassFunction(jsonDecode(jsonEncode(formDataMap)),
                      dataTypes, count2, myList2);
                  return areListsEqual(myList1, myList2);
                });

                // differance == null
                if (differance == null) {
                  count11++;
                  methodRequestModel['${method.name.toString().snakeCase}'] =
                  '${feature?.name}$count11';
                  // methodListReturnModelNameForAll.add(AddJson(
                  //     body: json.encode(formDataMap),
                  //     modelName: '${feature?.name}${count22}_request'));
                  methodListReturnModelNameForAll.add(AddJson(
                      body: json.encode(formDataMap),
                      modelName: '${feature?.name}$count11'));
                } else {
                  // methodRequestModel[method.name.toString().snakeCase] =
                  //     '${feature?.name}${count22}_request';
                  methodRequestModel[method.name.toString().snakeCase] =
                  '${feature?.name}$count11';
                }
              }
            }
          }
        } else {
          //add to error list
          errorListForJson.add('featureName : ${feature?.name}'
              ', Error : method request is null.');
        }
      }

      //add to map
      jsonMap['${feature?.name.toString().snakeCase}'] =
          methodListReturnModelNameForAll;
      // jsonMapRequest['${feature?.name.toString().snakeCase}'] =
      //     methodListRequestModelNameForAll;
    }
  }

  if (errorHandle.isEmpty) {
    errorHandle = "{\"code\":\"INVALID_DATA\",\"details\":{},"
        "\"message\":\"message\",\"status\":\"error\"}";
  }
  //add to json map

  jsonMap['common_error_handle_model'] = [
    {'body': errorHandle.toString(), 'model_name': 'common_error_handle_model'}
  ];

//  return errorListForJson;
}

Future<Postman?> getModelString(String link) async {
  late Dio dio;
  BaseOptions options = BaseOptions(
    //https://www.getpostman.com/collections/b4c91b51210e616745bd
    //https://www.getpostman.com/collections/b4c91b51210e616745bd
    // baseUrl: "https://www.getpostman.com/collections/",
    connectTimeout: 20 * 1000,
    receiveTimeout: 20 * 1000,
    receiveDataWhenStatusError: true,
  );
  try {
    dio = Dio(options);
    //b4c91b51210e616745bd my demo
    // cd3a713a3117ac02a308 zoho
    Response response = await dio.get(link);
    var data = response.data;
    return Postman.fromJson(data);
  } on DioError catch (e) {
    print('Error:-> \n Something went wrong... ');
    print(e.message);
    return null;
  } catch (e, stackTrace) {
    print('Error:-> \n Something went wrong... ');
    print(format(stackTrace));
  }
  return null;
}

String format(StackTrace stackTrace, {bool terse = true}) {
  var trace = Trace.from(stackTrace);
  if (terse) trace = trace.terse;
  return trace.toString();
}

Future<Map<String, List<String>>> setModel(Map<String, dynamic> jsonMap) async {
  late Dio dio;
  BaseOptions options = BaseOptions(
    //TODO replace ngrok link
    baseUrl: "https://2f91-180-211-112-179.in.ngrok.io/",
    connectTimeout: 60 * 1000,
    receiveTimeout: 60 * 1000,
    contentType: 'application/json',
    receiveDataWhenStatusError: true,
  );
  Map<String, List<String>> map = {};
  try {
    var dir = Directory.systemTemp.createTempSync();
    await File("${dir.path}/json_file.json").create().then((file) async {
      file = await file.writeAsString(json.encode(jsonMap));
      dio = Dio(options);
      FormData formData = FormData.fromMap({
        "name": "Model",
        "file": await MultipartFile.fromFile(
          file.path,
        ),
      });
      Response response = await dio.post("json-file-to-model-latest",
          data: formData,
          options: Options(headers: {
            'content-length': formData.length,
          }));
      var data = response.data['model'] as Map<String, dynamic>;

      Map<String, List<String>> finalMap = {};
      data.forEach((key, value) {
        List<String> list = List.from(value);
        finalMap[key] = list;
      });
      map = finalMap;
    });
  } on DioError catch (e) {
    print('Error:-> \n Something went wrong... ');
    print(e.message);
  } catch (e, stackTrace) {
    print('Error:-> \n Something went wrong... ');
    print(format(stackTrace));
  }
  return map;
}

//method
Future<void> commonMethodCall(
    List<dynamic> getMethods,
    ItemItem method,
    List<HeaderList> finalHeaders,
    String featureName,
    featureModelMap,
    Map<String, dynamic> jsonMap,
    Map<String, dynamic> methodReturnModel,
    Map<String, dynamic> methodRequestModel) async {
  try {
    Map<String, dynamic> maps = Map();
    maps['is_put'] = method.request?.method.toString() == 'PUT';
    //maps['model_name'] = '${featureName.camelCase}_model';
    maps['method_name'] = method.name ?? 'methodName';
    maps['future'] = false;
    maps['stream'] = true;
    var finalEndPoint = '';
    if (method.request != null) {
      if (method.request!.url != null) {
        if (method.request!.url.runtimeType.toString() == "String") {
          finalEndPoint = setEndPointFromUrl(method.request!.url, false);

          setEndPointParam(finalEndPoint, maps);
          maps['query_param_type'] = '';
          maps['query_param'] = [];
          maps['query_param_comma'] = '';
        } else {
          if (method.request!.url['raw'] != null) {
            finalEndPoint =
                setEndPointFromUrl(method.request!.url['raw'], true);
            setEndPointParam(finalEndPoint, maps);
            setQueryParam(method.request!.url['query'], maps);
          } else {}
        }

        setHeaders(method.request!.header ?? [], finalHeaders, maps,
            method.request?.auth);
        setUrl(maps);
        setJson(method.response ?? [], maps, method.name.toString(),
            featureModelMap, jsonMap, methodReturnModel, featureName);
        setRequestBody(
            method.request, methodRequestModel, method.name.toString(), maps);
      } else {
        // add to error list

      }
    } else {
      // add to error list

    }
    getMethods.add(maps);
  } catch (e, stackTrace) {
    print('Error:-> \n Something went wrong... ');
    print(format(stackTrace));
  }
}

// util method
void setRequestBody(Request? request, Map<String, dynamic> methodRequestModel,
    String name, Map<String, dynamic> maps) {
  try {
    if (request != null && request.body != null) {
      if (methodRequestModel[name.snakeCase] == null) {
        maps['data_model_class_name'] = '';
        maps['data_model_name'] = '';
      } else {
        maps['data_model_class_name'] =
            methodRequestModel[name.snakeCase].toString().pascalCase;
        maps['data_model_name'] =
            methodRequestModel[name.snakeCase].toString().camelCase;
      }
      if (request.body!.mode == 'raw') {
        if (request.body!.raw!.isEmpty) {
          maps['is_data_model'] = false;
        } else {
          maps['is_data_model'] = true;
        }
        maps['is_raw'] = true;
      } else {
        // form data
        if (request.body!.formdata!.isEmpty) {
          maps['is_data_model'] = false;
        } else {
          maps['is_data_model'] = true;
        }
        maps['is_raw'] = false;
        //setFormDataParam(request.body?.formdata ?? [], maps);
      }
    } else {
      maps['is_data_model'] = false;
    }
  } catch (e, stackTrace) {
    print('Error:-> \n Something went wrong... ');
    print(format(stackTrace));
  }
}

List<dynamic> setListOfModels(
    Map<String, List<String>> featureModelMap, String featureName) {
  List<dynamic> repo = [];
  var regexp = RegExp("\\b(class)\\b", caseSensitive: true);
  List<String> methodsList = featureModelMap['${featureName.snakeCase}'] ?? [];
  for (var response in methodsList) {
    final listString = response.split(regexp);
    List<String> modelList = [];
    for (var item1 in listString) {
      if (item1.isNotEmpty) {
        var start = "${item1.split(' ')[1]} copyWith({";
        // List<String> list = List.from(item1.split(' ').join(''));
        const end = "})";
        var endFinal = ');}';
        final startIndex = item1.indexOf(start);
        final endFinalIndex =
        item1.indexOf(endFinal, startIndex + start.length);
        final endIndex = item1.indexOf(end, startIndex + start.length);
        if (item1
            .substring(startIndex + start.length, endIndex)
            .trim()
            .isEmpty) {
          item1 = item1.replaceRange(startIndex, endFinalIndex, '');
          item1 = item1.replaceAll(endFinal, '');
        }
        modelList.add(item1.split(' ')[1]);
        repo.add({'model_name_model': item1.split(' ')[1], 'data': item1});
      }
    }
  }
  print('repo:::::::::::::::::::::::::::::::::$repo');
  return repo;
}

void setJson(
    List<PostmanResponse?> response,
    Map<String, dynamic> maps,
    String methodName,
    featureModelMap,
    Map<String, dynamic> jsonMap,
    Map<String, dynamic> methodReturnModel,
    String featureName) {
  try {
    maps['return_model_name'] =
        '${methodReturnModel[methodName.snakeCase]}'.pascalCase;
    maps['model_name'] = maps['return_model_name'].toString().camelCase;
    //default true
    maps['is_return_model'] = true;
    maps['is_return_dynamic'] = false;
    List<AddJson> jsonMapBody = jsonMap[featureName.snakeCase];
    String body = jsonMapBody[0].body.toString();
    if (body[0] == '{') {
      maps['is_list'] = false;
    } else if (body[0] == '[') {
      maps['is_list'] = true;
    }
    // return maps;
  } catch (e, stackTrace) {
    print('Error:-> \n Something went wrong... ');
    print(format(stackTrace));
  }
}

void setUrl(Map<String, dynamic> maps) {
  maps['uri_method'] = 'ApiServerConfig.uri';
}

void setQueryParam(List<dynamic> listQuery, Map<String, dynamic> maps) {
  String queryParamComma = '';
  String queryParamType = '';
  final queryParamList = [];
  final queryParamSetList = [];
  for (var item in listQuery) {
    if (item['value'].toString().contains(RegExp('\\{(.*?)\\}'))) {
      queryParamComma = queryParamComma + '${item['key']},';
      queryParamType = queryParamType + 'String ${item['key']}';
      queryParamList.add({'param': item['key'].toString()});
      queryParamSetList.add({'param': '${item['key']} : ${item['key']}'});
    } else {
      queryParamSetList.add({'param': '${item['key']} : ${item['value']}'});
    }
  }
  maps['query_param_set'] = queryParamSetList;
  maps['query_param'] = queryParamList;
  maps['query_param_type'] = queryParamType;
  maps['query_param_comma'] = queryParamComma;
  maps['is_query_param'] = maps['query_param'].isNotEmpty;
}

String replaceBracketWithDollar(String subString, RegExp reg,
    [bool isHeader = false]) {
//  RegExp reg = RegExp('\\{(.*?)\\}');
  return subString.replaceAllMapped(
    reg,
        (match) {
      if (isHeader) {
        return "\${${match[0].toString().replaceAll(RegExp(r'[{}]'), '').toString().camelCase}}";
      } else {
        return "\$${match[0].toString().replaceAll(RegExp(r'[{}]'), '').toString().camelCase}";
      }
    },
  );
}

String replaceDoubleBracketWithDollar(String subString, RegExp reg) {
//  RegExp reg = RegExp('\\{(.*?)\\}');
  return subString.replaceAllMapped(
    reg,
        (match) {
      return "\$${match[0].toString().camelCase.replaceAll(RegExp(r'[{{}}]'), '')}";
    },
  );
}

String setEndPointFromUrl(url, bool isQueryParam) {
  List<String> listUrl = url.split('}}/');
  var subString = listUrl.last;
  var endPoint;
  if (subString.contains(RegExp('\\{{(.*?)\\}}'))) {
    endPoint = replaceBracketWithDollar(subString, RegExp('\\{{(.*?)\\}}'));
  } else {
    endPoint = replaceDoubleBracketWithDollar(subString, RegExp('\\{(.*?)\\}'));
  }
  var finalEndPoint = '';
  if (isQueryParam) {
    finalEndPoint = endPoint.split('?')[0];
  } else {
    finalEndPoint = endPoint;
  }
  return finalEndPoint;
}

Map<String, dynamic>? recursiveCall(Map<String, dynamic> currentMap,
    Map<String, dynamic> dataTypes, Map<String, dynamic> data) {
  DataObject dataObject = DataObject.fromJson(currentMap);
  if (dataObject.properties != null) {
    Map<String, dynamic> currentSimpleMap = {};
    dataObject.properties!.forEach((key, value) {
      //key -> field name
      Properties properties = Properties.fromJson(value);
      if (dataTypes.keys.contains(properties.type)) {
        // datatype
        currentSimpleMap[key] = dataTypes[properties.type];
      } else if (properties.type == 'array' && properties.items != null) {
        if (properties.items!.type != null &&
            dataTypes.keys.contains((properties.items?.type ?? ''))) {
          currentSimpleMap[key] = [dataTypes[properties.items?.type]];
          // ['']
        } else if ((properties.items?.ref ?? '').isNotEmpty) {
          // [object]
          currentSimpleMap[key] = [
            recursiveCall(getMap(properties.items?.ref, data), dataTypes, data)
          ];
        }
      } else if ((properties.ref ?? '').isNotEmpty) {
        // object
        currentSimpleMap[key] =
            recursiveCall(getMap(properties.ref, data), dataTypes, data);
      }
    });
    print('currentSimpleMap:::::::::::::::$currentSimpleMap');
    return currentSimpleMap;
  }
  return null;
}

void setEndPointParam(String finalEndPoint, Map<String, dynamic> maps) {
  var list = finalEndPoint.split('/');
  var list2 = [];
  var list1 = [];
  var list3 = [];
  //client/$id/$name
  for (var item in list) {
    if (item.isNotEmpty && item.contains('\$')) {
      list3.add({'name': '${item.replaceAll('\$', '').trim()}'});
      list1.add('${item.replaceAll('\$', '').trim()}');
      list2.add('dynamic ${item.replaceAll('\$', '').trim()}');
    }
  }
  if (list1.isEmpty) {
    maps['is_params'] = false;
    maps['is_no_params'] = true; // TODO {remove this key value.}
  } else {
    maps['is_params'] = true;
    maps['is_no_params'] = false; // TODO {remove this key value.}
  }
  maps['end_point_fields'] = list2.join(',');
  maps['end_point_fields_params'] = list1.join(',');
  maps['end_point_fields_params_usecase'] = list3;
  maps['end_point'] = finalEndPoint;
  maps['is_end_point_fields'] = maps['end_point_fields'].isNotEmpty;
}

void setHeaders(List<Header?> headerList, List<HeaderList> finalHeaders,
    Map<String, dynamic> maps, Auth? auth) {
  try {
    Header? header = headerList
        .firstWhereOrNull((element) => element!.key == 'Authorization');
    if (header != null) {
      headerList.removeWhere((element) => element!.key == 'Authorization');
      headerList.add(header.copyWith(value: 'Bearer {{authorization-token}}'));
    } else if (auth != null && header == null) {
      headerList.add(Header(
          key: 'Authorization',
          value: auth.bearer?.token != null
              ? 'Bearer {{authorization-token}}'
              : 'Add Your Token',
          description: '',
          type: '',
          disabled: false,
          src: ''));
    }

    if (finalHeaders.isEmpty) {
      if (headerList.isNotEmpty) {
        finalHeaders.add(HeaderList(
            headerName: 'headers1', headerList: headerList as List<Header>));
        maps['headers'] = 'APIServerConfig.headers1';
      }
    } else {
      // List<bool> boolList = [];
      var existingHeaderName = '';
      var bool = true;
      for (var item1 in finalHeaders) {
        int count = 0;
        for (var item2 in headerList) {
          if (item1.headerList.firstWhereOrNull((element) {
            return element.key == item2!.key &&
                element.value == item2.value;
          }) !=
              null) {
            count++;
            existingHeaderName = item1.headerName.toString();
          }
        }
        if (count == headerList.length) {
          bool = false;
          break;
        }
      }
      if (bool) {
        //add new header
        finalHeaders.add(HeaderList(
            headerName: 'headers${finalHeaders.length + 1}',
            headerList: headerList as List<Header>));
        maps['headers'] = 'APIServerConfig.headers${finalHeaders.length}';
      } else {
        //header already added
        maps['headers'] = 'APIServerConfig.$existingHeaderName';
      }
    }
  } catch (e, stackTrace) {
    print(format(stackTrace));
  }
}

//model

class DataObject {
  String? type;
  String? title;
  Map<String, dynamic>? properties;

  DataObject({this.type, this.title, this.properties});

  factory DataObject.fromJson(Map<String, dynamic> json) {
    return DataObject(
        type: json["type"] ?? '',
        properties: json["properties"],
        title: json["title"] ?? '');
  }
}

class Properties {
  Properties({this.type, this.items, this.ref});

  String? type;
  Items? items;
  String? ref;

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
        type: json["type"] ?? '',
        items: json["items"] == null ? null : Items.fromJson(json["items"]),
        ref: json["\$ref"] ?? '');
  }
}

class Parameters {
  Parameters(
      {this.name,
        this.ins,
        this.description,
        this.type,
        this.required,
        this.schema});

  String? name;
  String? ins;
  String? description;
  String? type;
  bool? required;
  Schema? schema;

  factory Parameters.fromJson(Map<String, dynamic> json) {
    return Parameters(
        name: json["name"] ?? '',
        description: json["description"] ?? '',
        type: json["type"] ?? '',
        required: json["required"] ?? true,
        ins: json["in"] ?? '',
        schema:
        json["schema"] == null ? null : Schema.fromJson(json["schema"]));
  }
}

class Schema {
  String? type;
  Items? items;
  String? ref;
  String? desc;

  Schema({this.type, this.items, this.ref, this.desc});

  factory Schema.fromJson(Map<String, dynamic> json) {
    return Schema(
        ref: json["\$ref"] != null ? json["\$ref"].toString() : '',
        type: json["type"] ?? '',
        desc: json["description"] ?? '',
        items: json["items"] != null ? Items.fromJson(json["items"]) : null);
  }
}

class Items {
  String? ref;
  String? type;

  Items({this.ref, this.type});

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
        ref: json["\$ref"] != null ? json["\$ref"].toString() : '',
        type: json["type"] != null ? json["type"].toString() : '');
  }
}

class Postman {
  Postman({
    required this.info,
    required this.item,
  });

  late Info? info;
  late List<PostmanItem?>? item;

  Postman copyWith({Info? info, List<PostmanItem?>? item}) =>
      Postman(info: info ?? this.info, item: item ?? this.item);

  factory Postman.fromRawJson(String str) => Postman.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Postman.fromJson(Map<String, dynamic> json) {
    info = json["info"] != null ? new Info.fromJson(json["info"]) : null;
    item = json["item"] == null
        ? null
        : List<PostmanItem>.from(
        json["item"]?.map((x) => new PostmanItem.fromJson(x)));
  }

  Map<String, dynamic> toJson() => {
    "info": info?.toJson(),
    "item": item != null
        ? List<PostmanItem?>.from(item!.map((x) => x!.toJson()))
        : null,
  };
}

class Info {
  Info({
    required this.postmanId,
    required this.name,
    required this.description,
    required this.schema,
  });

  final String? postmanId;
  final String? name;
  final String? description;
  final String? schema;

  factory Info.fromRawJson(String str) => Info.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      postmanId: json["_postman_id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      schema: json["schema"] ?? "",
    );
  }

  @override
  String toString() {
    return '$postmanId, $name, $description, $schema';
  }

  Map<String, dynamic> toJson() => {
    "_postman_id": postmanId,
    "name": name,
    "description": description,
    "schema": schema,
  };
}

class PostmanItem {
  PostmanItem({
    required this.name,
    required this.item,
    required this.id,
  });

  final String? name;
  final List<ItemItem?>? item;
  final String? id;

  factory PostmanItem.fromRawJson(String str) =>
      PostmanItem.fromJson(json.decode(str));

  PostmanItem copyWith({String? name, List<ItemItem?>? item, String? id}) =>
      PostmanItem(
          name: name ?? this.name, item: item ?? this.item, id: id ?? this.id);

  String toRawJson() => json.encode(toJson());

  factory PostmanItem.fromJson(Map<String, dynamic> json) {
    return PostmanItem(
      name: json["name"] ?? "",
      item: json["item"] == null
          ? []
          : List<ItemItem>.from(json["item"].map((x) => ItemItem.fromJson(x))),
      id: json["id"] ?? "",
    );
  }

  @override
  String toString() {
    return '$name, $item, $id';
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "item": item != null
        ? List<ItemItem>.from(item!.map((x) => x!.toJson()))
        : null,
    "id": id,
  };
}

class ItemItem {
  ItemItem({
    required this.name,
    required this.id,
    required this.request,
    required this.response,
    required this.event,
  });

  final String? name;
  final String? id;
  final Request? request;
  final List<PostmanResponse?>? response;
  final List<Event>? event;

  factory ItemItem.fromRawJson(String str) =>
      ItemItem.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ItemItem.fromJson(Map<String, dynamic> json) {
    return ItemItem(
      name: json["name"] ?? "",
      id: json["id"] ?? "",
      request:
      json["request"] == null ? null : Request.fromJson(json["request"]),
      response: json["response"] == null
          ? []
          : List<PostmanResponse>.from(
          json["response"]!.map((x) => PostmanResponse.fromJson(x))),
      event: json["event"] == null
          ? []
          : List<Event>.from(json["event"]!.map((x) => Event.fromJson(x))),
    );
  }

  @override
  String toString() {
    return '$name, $id, $request, $response, $event';
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "id": id,
    "request": request?.toJson(),
    "response": List<dynamic>.from(response!.map((x) => x)),
    "event": List<Event>.from(event!.map((x) => x.toJson())),
  };
}

class PostmanResponse {
  PostmanResponse({
    this.id,
    this.name,
    this.originalRequest,
    this.status,
    this.code,
    this.postmanPreviewlanguage,
    this.header,
    this.cookie,
    this.body,
  });

  String? id;
  String? name;
  OriginalRequest? originalRequest;
  String? status;
  int? code;
  String? postmanPreviewlanguage;
  List<Header?>? header;
  List<dynamic>? cookie;
  String? body;

  factory PostmanResponse.fromRawJson(String str) =>
      PostmanResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PostmanResponse.fromJson(Map<String, dynamic> json) =>
      PostmanResponse(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        originalRequest: json["originalRequest"] == null
            ? null
            : OriginalRequest.fromJson(json["originalRequest"]),
        status: json["status"] == null ? null : json["status"],
        code: json["code"] == null ? null : json["code"],
        postmanPreviewlanguage: json["_postman_previewlanguage"] == null
            ? null
            : json["_postman_previewlanguage"],
        header: json["header"] == null
            ? null
            : List<Header>.from(json["header"].map((x) => Header.fromJson(x))),
        cookie: json["cookie"] == null
            ? null
            : List<dynamic>.from(json["cookie"].map((x) => x)),
        body: json["body"] == null ? null : json["body"],
      );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "originalRequest":
    originalRequest == null ? null : originalRequest!.toJson(),
    "status": status == null ? null : status,
    "code": code == null ? null : code,
    "_postman_previewlanguage":
    postmanPreviewlanguage == null ? null : postmanPreviewlanguage,
    "header": header == null
        ? null
        : List<dynamic>.from(header!.map((x) => x!.toJson())),
    "cookie":
    cookie == null ? null : List<dynamic>.from(cookie!.map((x) => x)),
    "body": body == null ? null : body,
  };
}

class OriginalRequest {
  OriginalRequest({
    this.method,
    this.header,
    this.body,
    this.url,
  });

  String? method;
  List<Header>? header;
  Body? body;
  dynamic url;

  factory OriginalRequest.fromRawJson(String str) =>
      OriginalRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OriginalRequest.fromJson(Map<String, dynamic> json) {
    // var urlReturn;
    // if (json["url"] != null) {
    //   if (json["url"].runtimeType.toString() == 'String') {
    //     urlReturn = json["url"];
    //   } else {
    //     //TODO object
    //     urlReturn = json["url"];
    //   }
    // } else {
    //   urlReturn = null;
    // }

    return OriginalRequest(
      method: json["method"] == null ? null : json["method"],
      header: json["header"] == null
          ? null
          : List<Header>.from(json["header"].map((x) => Header.fromJson(x))),
      body: json["body"] == null ? null : Body.fromJson(json["body"]),
      url: json["url"] == null ? null : json["url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "method": method == null ? null : method,
    "header":
    header == null ? null : List<dynamic>.from(header!.map((x) => x)),
    "body": body == null ? null : body!.toJson(),
    "url": url == null ? null : url,
  };
}

class Event {
  Event({
    required this.listen,
    required this.script,
  });

  final String? listen;
  final Script? script;

  factory Event.fromRawJson(String str) => Event.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      listen: json["listen"] ?? "",
      script: json["script"] == null ? null : Script.fromJson(json["script"]),
    );
  }

  @override
  String toString() {
    return '$listen, $script';
  }

  Map<String, dynamic> toJson() => {
    "listen": listen,
    "script": script?.toJson(),
  };
}

class Script {
  Script({
    required this.type,
    required this.exec,
  });

  final String? type;
  final List<String?>? exec;

  factory Script.fromRawJson(String str) => Script.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Script.fromJson(Map<String, dynamic> json) {
    return Script(
      type: json["type"] ?? "",
      exec: json["exec"] == null
          ? []
          : List<String>.from(json["exec"]!.map((x) => x)),
    );
  }

  @override
  String toString() {
    return '$type, $exec';
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "exec": List<String>.from(exec!.map((x) => x)),
  };
}

class Request {
  Request({
    this.auth,
    required this.method,
    required this.header,
    required this.body,
    required this.url,
    required this.description,
  });

  final String? method;
  final List<Header?>? header;
  final Body? body;
  final Auth? auth;
  final dynamic url;
  final String? description;

  factory Request.fromRawJson(String str) => Request.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      auth: json['auth'] == null ? null : Auth.fromJson(json['auth']),
      method: json["method"] ?? "",
      header: json["header"] == null
          ? []
          : List<Header>.from(json["header"]!.map((x) => Header.fromJson(x))),
      body: json["body"] == null ? null : Body.fromJson(json["body"]),
      url: json["url"],
      description: json["description"] ?? "",
    );
  }

  @override
  String toString() {
    return '$method, $header, $body, $url, $description';
  }

  Map<String, dynamic> toJson() => {
    "method": method,
    "header": List<Header>.from(header!.map((x) => x!.toJson())),
    "body": body?.toJson(),
    "url": url,
    "description": description,
  };
}

class Auth {
  Auth({
    this.type,
    this.bearer,
  });

  String? type;
  Bearer? bearer;

  factory Auth.fromRawJson(String str) => Auth.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
    type: json["type"] == null ? null : json["type"],
    bearer: json["bearer"] == null ? null : Bearer.fromJson(json["bearer"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type == null ? null : type,
    "bearer": bearer == null ? null : bearer!.toJson(),
  };
}

class Bearer {
  Bearer({
    this.token,
  });

  String? token;

  factory Bearer.fromRawJson(String str) => Bearer.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Bearer.fromJson(Map<String, dynamic> json) => Bearer(
    token: json["token"] == null ? null : json["token"],
  );

  Map<String, dynamic> toJson() => {
    "token": token == null ? null : token,
  };
}

class Body {
  Body({
    required this.mode,
    required this.formdata,
    required this.raw,
  });

  final String? mode;
  final List<Header?>? formdata;
  final String? raw;

  factory Body.fromRawJson(String str) => Body.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Body.fromJson(Map<String, dynamic> json) {
    return Body(
      mode: json["mode"] ?? "",
      formdata: json["formdata"] == null
          ? []
          : List<Header>.from(json["formdata"]!.map((x) => Header.fromJson(x))),
      raw: json["raw"] ?? "",
    );
  }

  @override
  String toString() {
    return '$mode, $formdata, $raw';
  }

  Map<String, dynamic> toJson() => {
    "mode": mode,
    "formdata": List<Header>.from(formdata!.map((x) => x!.toJson())),
    "raw": raw,
  };
}

class Header {
  Header({
    required this.key,
    required this.value,
    required this.description,
    required this.type,
    required this.disabled,
    required this.src,
  });

  final String? key;
  final String? value;
  final String? description;
  final String? type;
  final bool? disabled;
  final dynamic src;

  factory Header.fromRawJson(String str) => Header.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Header copyWith({
    String? key,
    String? value,
    String? description,
    String? type,
    bool? disabled,
    dynamic src,
  }) =>
      Header(
          key: key ?? this.key,
          value: value ?? this.value,
          description: description ?? this.description,
          type: type ?? this.type,
          disabled: disabled ?? this.disabled,
          src: src ?? this.src);

  factory Header.fromJson(Map<String, dynamic> json) {
    return Header(
      key: json["key"] ?? "",
      value: json["value"] ?? "",
      src: json["src"] ?? "",
      description: json["description"] ?? "",
      type: json["type"] ?? "",
      disabled: json["disabled"] ?? false,
    );
  }

  @override
  String toString() {
    return '$key, $value, $description, $type, $disabled, $src';
  }

  Map<String, dynamic> toJson() => {
    "key": key,
    "value": value,
    "description": description,
    "type": type,
    "disabled": disabled,
    "src": src
  };
}

class UrlClass {
  UrlClass({
    required this.raw,
    required this.protocol,
    required this.host,
    required this.path,
    required this.query,
  });

  final String? raw;
  final String? protocol;
  final List<String?>? host;
  final List<String?>? path;
  final List<Query?>? query;

  factory UrlClass.fromRawJson(String str) =>
      UrlClass.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UrlClass.fromJson(Map<String, dynamic> json) {
    return UrlClass(
      raw: json["raw"] ?? "",
      protocol: json["protocol"] ?? "",
      host: json["host"] == null
          ? []
          : List<String>.from(json["host"]!.map((x) => x)),
      path: json["path"] == null
          ? []
          : List<String>.from(json["path"]!.map((x) => x)),
      query: json["query"] == null
          ? []
          : List<Query>.from(json["query"]!.map((x) => Query.fromJson(x))),
    );
  }

  @override
  String toString() {
    return '$raw, $protocol, $host, $path, $query';
  }

  Map<String, dynamic> toJson() => {
    "raw": raw,
    "protocol": protocol,
    "host": List<String>.from(host!.map((x) => x)),
    "path": List<String>.from(path!.map((x) => x)),
    "query": List<Query>.from(query!.map((x) => x!.toJson())),
  };
}

class Query {
  Query({
    required this.key,
    required this.value,
  });

  final String? key;
  final String? value;

  factory Query.fromRawJson(String str) => Query.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Query.fromJson(Map<String, dynamic> json) {
    return Query(
      key: json["key"] ?? "",
      value: json["value"] ?? "",
    );
  }

  @override
  String toString() {
    return '$key, $value';
  }

  Map<String, dynamic> toJson() => {
    "key": key,
    "value": value,
  };
}

class AddJson {
  String body;
  String modelName;

  AddJson({required this.body, required this.modelName});

  @override
  String toString() {
    return '$body, $modelName';
  }

  factory AddJson.fromJson(Map<String, dynamic> json) {
    return AddJson(
      body: json["body"] ?? "",
      modelName: json["model_name"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "body": body,
    "model_name": modelName,
  };
}

class HeaderList {
  String headerName;
  List<Header> headerList;

  HeaderList({required this.headerName, required this.headerList});

  @override
  String toString() {
    return '$headerName, $headerList';
  }

  factory HeaderList.fromJson(Map<String, dynamic> json) {
    return HeaderList(
      headerName: json["header_name"] ?? "",
      headerList: json["header_list"] ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    "header_name": headerName,
    "header_list": headerList,
  };
}

//
void newClassFunction(Map newMap, List<String> dataTypes, int count,
    List<Map<int, dynamic>> myList,
    [bool isList = false]) {
  var map = newMap;
  List<String> list1 = [];

  map.forEach((key, value) {
    if (value.runtimeType.toString().contains("Array")) {
      if (value.runtimeType.toString().contains("Object")) {
        myList.add({
          count: {key: value.runtimeType.toString()}
        });
        newClassFunction(value[0], dataTypes, count, myList, true);
      } else if (value.runtimeType.toString().contains("List") &&
          value.runtimeType.toString().contains("Map")) {
        myList.add({
          count: {key: value.runtimeType.toString()}
        });
        newClassFunction(value[0], dataTypes, count, myList, true);
      } else if (!value.runtimeType.toString().contains("Map")) {
        var isDynamic = true;
        var dataType = "";
        for (var item in dataTypes) {
          if (value.runtimeType.toString().contains(item)) {
            isDynamic = false;
            dataType = item;
            break;
          }
        }
        if (!isDynamic) {
          list1.add("List<$dataType> $key ${count++}");
          myList.add({
            count: {key: value.runtimeType.toString()}
          });
        }
      } else if (value.runtimeType.toString().contains("dynamic, dynamic")) {
        myList.add({
          count: {key: value.runtimeType.toString()}
        });
        newClassFunction(value[0], dataTypes, count, myList, true);
      } else if (value.runtimeType.toString().contains("Map")) {
        var isDynamic = false;
        var dataType = "";
        for (var item in dataTypes) {
          if (value.runtimeType.toString().contains('$item>>') ||
              value.runtimeType.toString().contains('$item?>>')) {
            isDynamic = true;
            dataType = item;
            break;
          }
        }
        if (!isDynamic) {
          list1.add("List<$dataType> $key ${count++}");
          myList.add({
            count: {key: value.runtimeType.toString()}
          });
        } else {
          myList.add({
            count: {key: value.runtimeType.toString()}
          });
          newClassFunction(value[0], dataTypes, count, myList, true);
        }
      } else {
        myList.add({
          count: {key: value.runtimeType.toString()}
        });
        newClassFunction(value[0], dataTypes, count, myList, true);
      }
    } else if (value.runtimeType.toString().contains("Map")) {
      if (value.runtimeType.toString().contains("Array")) {
        myList.add({
          count: {key: value.runtimeType.toString()}
        });
        newClassFunction(value[0], dataTypes, count, myList, true);
      } else {
        myList.add({
          count: {key: value.runtimeType.toString()}
        });
        newClassFunction(value, dataTypes, count, myList);
      }
    } else if (dataTypes.contains(value.runtimeType.toString())) {
      list1.add("${value.runtimeType.toString()} $key ${count++}");
      myList.add({
        count: {key: value.runtimeType.toString()}
      });
    }
  });
}

bool areListsEqual(var list1, var list2) {
  // check if both are lists
  if (!(list1 is List && list2 is List)
      // check if both have same length
      ||
      list1.length != list2.length) {
    return false;
  }
  // check if elements are equal
  for (int i = 0; i < list1.length; i++) {
    if (list1[i].values.first.keys.first != list2[i].values.first.keys.first ||
        list1[i].values.first.values.first !=
            list2[i].values.first.values.first) {
      return false;
    }
  }
  return true;
}

Future<Map<String, dynamic>> getSwaggerJson(String link) async {
  late Dio dio;
  BaseOptions options = BaseOptions(
    connectTimeout: 60 * 1000,
    receiveTimeout: 60 * 1000,
    contentType: 'application/json',
    receiveDataWhenStatusError: true,
  );
  dio = Dio(options);
  try {
    Response response = await dio.getUri(Uri.parse(link));
    var data = response.data as Map<String, dynamic>;
    return data;
  } on DioError catch (e, s) {
    print('Error-> ${e.message}');
    print('StackTrace-> ${s.toString()}');
    return {};
  } catch (e, s) {
    print('Error-> ${e.toString()}');
    print('StackTrace-> ${s.toString()}');
    return {};
  }
}

getMap(String? ref, Map<String, dynamic> data) {
  try {
    if (ref != null) {
      List<String> split = ref.split('/');
      return data[split[1]][split.last];
    }
    return null;
  } catch (e) {
    return null;
  }
}
