
import 'package:eimzo_id_example/ui/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'login_viewmodel.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      builder: (context, model, child)=> Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: model.sendController,
                  decoration: InputDecoration(
                      labelText: 'API URL',
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      contentPadding: EdgeInsets.all(20.0)),
                  keyboardType: TextInputType.text,
                ),
              ),
              CustomButton(
                  title: 'Send',
                  onPressed: () {
                    print("Send");
                    model.send();
                  },
                  isLoading: model.isLoading),
              SizedBox(height: 10),
              Divider(height: 2,color: Colors.grey,),
              SizedBox(height: 20),
              Visibility(
                visible: model.isVisible,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '${model.responseSend}',
                      style: TextStyle(color: Colors.black,fontSize: 16),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: model.color, spreadRadius: 3),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Visibility(
                visible: model.isVisible,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: model.checkController,
                    decoration: InputDecoration(
                        labelText: 'CHECK URL',
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderSide:
                          const BorderSide(color: Colors.black, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        contentPadding: EdgeInsets.all(20.0)),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              Visibility(
                visible: model.isVisible,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: CustomButton(
                      title: 'DeepLink',
                      onPressed: () {
                        model.deepLink();
                      },
                      isLoading: false),
                ),
              ),
              SizedBox(height: 10),
              Visibility(
                visible: model.isDeepLinkMessageVisible,
                child: Text(
                  '${model.successMessage}',
                  style: TextStyle(color: Colors.black,fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      onModelReady: (model) => model.setContext(context),
      viewModelBuilder: () => LoginViewModel(),
    );
  }

}
