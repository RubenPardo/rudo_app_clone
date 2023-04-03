import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return widget.userData.isSesameOk ?? false
      ? _buildSesame(size)
      : _buildLinkSesame(size);
  }


  /// builded when the user does have the sesame linked
  Widget _buildSesame(Size size){
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Introduce la contraseña para empezar',style: CustomTextStyles.title3,),
            const SizedBox(height: 8,),
            PrimaryButton(onPressed: (){
              showModalBottomSheet(context: context, builder: (context) {
                return _buildLoginSesame(size);
              },);
            }, text: 'Vincular Sesame')
          ],
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