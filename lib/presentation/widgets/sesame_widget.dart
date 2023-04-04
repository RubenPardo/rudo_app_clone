
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_event.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_state.dart';
import 'package:rudo_app_clone/presentation/pages/time_record_page.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

class SesameWidget extends StatefulWidget {
  const SesameWidget({super.key, required this.userData});


  final UserData userData;

  @override
  State<SesameWidget> createState() => _SesameWidgetState();
}

class _SesameWidgetState extends State<SesameWidget> {

  FormGroup buildForm() => fb.group(<String, Object>{
        // obligado, minimo 8 caracteres, al menos un digito letra y carac. especial
        'password': FormControl<String>(
          validators: [Validators.required, Validators.minLength(6), Validators.pattern(r'^(?=.*\d)(?=.*[a-zA-Z]).+$')]
        ),
      });
  bool _passwordVisible = false;
  bool _formError = false;
  bool _sesameLoading = false;
  Timer? workingTimer;
  Duration duration = const Duration();

  @override
  void initState() {
    super.initState();

    
    // if false means it is not linked
    if(widget.userData.isSesameOk ?? false){
      // seaseme linked, init
      context.read<SesameBloc>().add(InitSesame());
    }
  }

  @override
  void dispose() {
    if(workingTimer!=null){
      workingTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<SesameBloc,SesameState>(
      builder: (context, state) {
        if(state is NoLinked){
          return _buildLinkSesame(size);
        }
        if(state is Loaded){
          return _buildSesame(size,state.info);
        }
        
        return const Padding(padding: EdgeInsets.all(8), child: Center(child: CircularProgressIndicator(),));
           
      }, 
      listener: (context, state) {
        if(state is Loading){
          setState(() {
            _sesameLoading = true;
          });
        }else{
          log(state.runtimeType.toString());
          setState(() {
            _sesameLoading = false;
          });
        }

        if(state is Loaded){

          // init the working or pause timer
          if(state.info.getLastStatus() == CheckType.checkIn || state.info.getLastStatus() == CheckType.pause){
            _initTimer(state.info);
          }
          // ------------
        
        }

        if(state is Error){
          log(state.message);
        }
      },
    );
  }



  /// start a timer of working time or paused time
  void _initTimer(CheckInfo info){
     setState(() {
        duration = info.getDurationLastCheck();
      });

      if(workingTimer!=null && workingTimer!.isActive){
        workingTimer!.cancel();
      }
      workingTimer = Timer.periodic(const Duration(seconds: 30), (timer) { 
          setState(() {
            duration = duration + const Duration(seconds: 30);
          });
      });
  }

  /// builded when the user does have the sesame linked
  Widget _buildSesame(Size size, CheckInfo info){
    return SizedBox(
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //----------------- title sesmae, 
              _buildTitleSesame(info),
              const SizedBox(height: 8,),
              // buttons
              _sesameLoading 
                ? const Padding(padding: EdgeInsets.all(8), child: Center(child: CircularProgressIndicator(),),)
                : _buildButtonSesame(size,info)
            ],
          ),
    );
  }

  Widget _buildTitleSesame(CheckInfo info){
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => TimeRecordPage(checkInfo: info),));
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          info.getLastStatus() != CheckType.checkout
                ? Text('Llevas ${duration.toString().split(':')[0]}:${duration.toString().split(':')[1]}h ${info.getLastStatus() == CheckType.checkIn ? 'trabajando' : 'de pausa'}'
                    ,style: CustomTextStyles.title3,) // ---> Llevas xx:xxh trabajando / de pausa
                : const Text('Estás out de la oficina'),
          const Icon(Icons.arrow_forward_ios, size: 12,color: AppColors.hintColor,),
        ],
      ),
    );
  }

  /// build the buttons of check in/out and pause
  Widget _buildButtonSesame(Size size, CheckInfo info){
    return SizedBox(
      width: size.width,
      child: info.lastCheck.status == CheckType.checkIn 
            // if the last status is check in, show the pause and checkout buttons
            ? Row(
              children: [
                Expanded(
                    child: PrimaryButton(onPressed: (){
                        
                      }, text: 'Pausa', color: AppColors.primaryColor,),
                  ),
                  const SizedBox(width: 8,),
                Expanded(
                    child: PrimaryButton(onPressed: (){
                        
                      }, text: 'Check out', color: AppColors.red,),
                  )
                
              ],
          )
         // else only the check in
        :  PrimaryButton(onPressed: (){
                
              }, text: 'Check in', color: AppColors.green,
          ),
          
    );
  }

  /// builded when the user does not have the sesame linked 
  Widget _buildLinkSesame(Size size){
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Introduce la contraseña para empezar',style: CustomTextStyles.title3,),
            const SizedBox(height: 8,),
            PrimaryButton(onPressed: (){
              showModalBottomSheet(context: context, builder: (context) {
                return _buildLoginSesame(size);
              },);
              // TODO quitar ,,, pruebas
              /*setState(() {
                _isEventsLoading = true;
                _isOfficeDaysLoading = true;
              });
              context.read<HomeBloc>().add(InitHome());*/
            }, text: 'Vincular Sesame')
          ],
        );
  }

  /// build the form of login sesame, it will be called from a bottom sheet modal
  Widget _buildLoginSesame(Size size){
    var padding = const EdgeInsets.symmetric(horizontal: 24);
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // title -------
            const SizedBox(height: 16,),
            const Text('Login Sesame',style: CustomTextStyles.title2,),
            const SizedBox(height: 8,),
            const Divider(),
            const SizedBox(height: 16,),
             // body text ------------
            Container(
              padding: padding,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child:  Text.rich(
                TextSpan(
                  style: CustomTextStyles.bodyLarge,
                  text: 'Para hacer check in necesitamos tu ',
                  children: [
                    TextSpan( text: 'contraseña de Sesame.' , style: CustomTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                    const TextSpan(text: '\n\nPrometemos usarla únicamente para fines de registro horario 😉')
                  ]
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // form --------------------
            const SizedBox(height: 16,),
            Expanded(
              child: ReactiveFormBuilder(
                  form: buildForm, 
                  builder: (context, formGroup, child) {
                    return Padding(
                      padding: padding,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ----------------------------------- password
                          ReactiveTextField<String>(
                            formControlName: 'password',
                            obscureText: !_passwordVisible,
                            validationMessages: {
                              ValidationMessage.required: (_)=> 'The password must not be empty',
                              ValidationMessage.minLength: (_)=> 'The password must be at least 6 characters',
                              ValidationMessage.pattern:(_)=> 'The password must contain at least one digit and one character'
                            },
                            textInputAction: TextInputAction.done,
                            decoration:  InputDecoration(
                              labelText: 'Contraseña sesame',
                              errorStyle: CustomTextStyles.textHint.copyWith(color: AppColors.red),
                              errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.red),borderRadius: BorderRadius.all(Radius.circular(16))),
                              errorMaxLines: 2,
                              hintStyle: !_formError ? CustomTextStyles.textHint : CustomTextStyles.textHint.copyWith(color: AppColors.red),
                              fillColor:  Colors.white,
                              filled: true,
                              border: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.hintColor),borderRadius: BorderRadius.all(Radius.circular(16))),
                              suffixIconColor: AppColors.hintColor,
                              suffixIcon: IconButton(
                                icon: Icon(_passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () {
                                  setState(() { _passwordVisible = !_passwordVisible;});
                                },
                              )
                            ),
                          ),
                          PrimaryButton(onPressed: (){
                            
                            //_removeFocus(context);
                            if(formGroup.valid){
                              setState(() => _formError = false,);
                              formGroup.markAllAsTouched();
                              //context.read<LoginBloc>().add(LogIn(formGroup.value));
                            }else {
                              formGroup.markAllAsTouched();
                              setState(() => _formError = true,);
                    
                            }
                          }, text: 'Guardar'),
                          // boton login
                          
                        ],
                      ),
                    );
                  },
                ),
            ),
            const SizedBox(height: 16,),

          ],
        ),
      );
    
      },
     );
  }

  

}