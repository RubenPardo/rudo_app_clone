import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/office_day.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_event.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_state.dart';
import 'package:rudo_app_clone/presentation/widgets/event_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/image_profile_user_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/office_days_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';
import 'package:reactive_forms/reactive_forms.dart';

class HomePage extends StatefulWidget {
  final UserData userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FormGroup buildForm() => fb.group(<String, Object>{
        // obligado, minimo 8 caracteres, al menos un digito letra y carac. especial
        'password': FormControl<String>(
          validators: [Validators.required, Validators.minLength(6), Validators.pattern(r'^(?=.*\d)(?=.*[a-zA-Z]).+$')]
        ),
      });
  bool _passwordVisible = false;
  bool _formError = false;

  List<OfficeDay> _officeDays = [];
  late bool _isOfficeDaysLoading;
  List<Event> _events = [];
  late bool _isEventsLoading;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(InitHome());
    _isOfficeDaysLoading = true;
    _isEventsLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocConsumer<HomeBloc,HomeState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 16),
              child: Column(
                children: [
                  _name(),
                  const SizedBox(height: 16,),
                  _sesame(size),
                  _buildOfficeDays(size),
                  _nextEvents(),
                  /// 
                ],
              ),
            ),
          );
        },
        listener: (context, state) {
          if(state is LoadedOfficeDays){
            setState(() {
              _isOfficeDaysLoading = false;
              _officeDays = state.officeDays;
            });
          }else if(state is LoadedEvents){
            setState(() {
              _isEventsLoading = false;
              _events = state.events;
            });
          }
        },
      ),
    );
  }

  Widget _name(){
    return Row(
      children: [
        ImageProfileUserWidget(userData:widget.userData),
        const SizedBox(width: 15,),
        Text("¡Hola ${widget.userData.firstName!}!",style: CustomTextStyles.title1,)
      ],
    );
  }

  /// return de card section with the content realtionated with sesame
  Widget _sesame(Size size){
    return _cardBody(
      child: Column(
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
        ),
    );
  }

  /// return de card section with the content realtionated with sesame
  Widget _buildOfficeDays(Size size){
    return _cardBody(
      child: SizedBox(
        width: size.width,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estos son los días que vas a venir a la oficina:',style: CustomTextStyles.title3,),
              const SizedBox(height: 8,),
              _isOfficeDaysLoading ? const Center(child: CircularProgressIndicator(),): OfficeDaysWidget(officeDays: _officeDays),
            ],
          ),
      ),
    );
  }

  ///
  Widget _nextEvents(){
    return _cardBody(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Próximos eventos',style: CustomTextStyles.title1,),
            const SizedBox(height: 8,),
            _isEventsLoading 
              ? const SizedBox(height: 100,child: Center(child: CircularProgressIndicator(),),)
              : ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _events.length,
                itemBuilder: (context, index) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _cardBody(elevation:3,child: EventWidget(event:_events[index])),),
              ),
          ],
        ),
    );
  }

  Widget _cardBody({required Widget child, double elevation = 0}){
    return Card(
      elevation: elevation,
      color: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Container(
        decoration: const  BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child
          ),
      )
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

