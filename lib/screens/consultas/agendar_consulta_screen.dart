import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class AgendarConsultaScreen extends StatefulWidget {
  const AgendarConsultaScreen({super.key});

  @override
  _AgendarConsultaScreenState createState() => _AgendarConsultaScreenState();
}

class _AgendarConsultaScreenState extends State<AgendarConsultaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  
  String? _psicologoSelecionado;
  DateTime? _dataSelecionada;
  String? _horarioSelecionado;
  String? _modalidadeSelecionada = 'Presencial';
  bool _isFirstConsultation = false;

  List<User> _psicologos = [];
  bool _loadingPsicologos = true; // usado no spinner
  String? _errorPsicologos; // usado para exibir snackbar e estado de erro

  final List<String> _horarios = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30', '18:00', '18:30'
  ];

  @override
  void initState() {
    super.initState();
    _carregarPsicologos();
  }

  Future<void> _carregarPsicologos() async {
    try {
      final list = await ApiService.getPsychologists();
      if (!mounted) return;
      setState(() {
        _psicologos = list;
        _loadingPsicologos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorPsicologos = 'Erro ao carregar psicólogos';
        _loadingPsicologos = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar psicólogos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: Text(
          'Agendar Consulta',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loadingPsicologos)
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Carregando profissionais...'),
                    ],
                  ),
                ),
              if (_errorPsicologos != null)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorPsicologos!,
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      ),
                      TextButton(
                        onPressed: _carregarPsicologos,
                        child: Text('Tentar novamente'),
                      )
                    ],
                  ),
                ),
              // Header com ícone
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.cyan[50],
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.event_available,
                        size: 40,
                        color: Colors.cyan[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Agendar Consulta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Selecione o psicólogo, data e horário para sua consulta',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40),
              
              // Seleção do Psicólogo - CORRIGIDO
              _buildSectionTitle('Psicólogo'),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonFormField<String>(
                  value: _psicologoSelecionado,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Selecione um psicólogo',
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.psychology, color: Colors.grey[600]),
                  ),
                  dropdownColor: Colors.white,
                  menuMaxHeight: 300,
                  items: _psicologos.map((p) {
                    final label = '${p.name} - ${p.specialty ?? 'Clínica Geral'}';
                    return DropdownMenuItem(
                      value: p.id, // Use ID as the value
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 100,
                        child: Text(label, style: const TextStyle(fontSize: 14)),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _psicologoSelecionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione um psicólogo';
                    }
                    return null;
                  },
                ),
              ),
              
              SizedBox(height: 24),
              
              // Data da Consulta
              _buildSectionTitle('Data da Consulta'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.grey[600]),
                  title: Text(
                    _dataSelecionada != null
                        ? '${_dataSelecionada!.day.toString().padLeft(2, '0')}/${_dataSelecionada!.month.toString().padLeft(2, '0')}/${_dataSelecionada!.year}'
                        : 'Selecione uma data',
                    style: TextStyle(
                      color: _dataSelecionada != null ? Colors.black87 : Colors.grey[500],
                    ),
                  ),
                  trailing: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  onTap: _selecionarData,
                ),
              ),
              
              SizedBox(height: 24),
              
              // Horário
              _buildSectionTitle('Horário'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonFormField<String>(
                  value: _horarioSelecionado,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Selecione o horário',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.access_time, color: Colors.grey[600]),
                  ),
                  items: _horarios.map((horario) {
                    return DropdownMenuItem(
                      value: horario,
                      child: Text(horario),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _horarioSelecionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione um horário';
                    }
                    return null;
                  },
                ),
              ),
              
              SizedBox(height: 24),
              
              // Modalidade da Consulta
              _buildSectionTitle('Modalidade da Consulta'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text('Presencial'),
                      subtitle: Text('Consulta no consultório'),
                      value: 'Presencial',
                      groupValue: _modalidadeSelecionada,
                      onChanged: (value) {
                        setState(() {
                          _modalidadeSelecionada = value;
                        });
                      },
                    ),
                    Divider(height: 1),
                    RadioListTile<String>(
                      title: Text('Online'),
                      subtitle: Text('Consulta por videochamada'),
                      value: 'Online',
                      groupValue: _modalidadeSelecionada,
                      onChanged: (value) {
                        setState(() {
                          _modalidadeSelecionada = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Primeira consulta?
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: CheckboxListTile(
                  title: Text('Esta é minha primeira consulta'),
                  subtitle: Text('Marque se for sua primeira vez com este psicólogo'),
                  value: _isFirstConsultation,
                  onChanged: (value) {
                    setState(() {
                      _isFirstConsultation = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              
              SizedBox(height: 24),
              
              // Motivo da Consulta
              _buildSectionTitle('Motivo da Consulta (Opcional)'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  controller: _motivoController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Descreva brevemente o motivo da consulta...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              
              SizedBox(height: 40),
              
              // Resumo da Consulta (se tiver dados preenchidos)
              if (_psicologoSelecionado != null || _dataSelecionada != null || _horarioSelecionado != null)
                _buildResumo(),
              
              SizedBox(height: 40),
              
              // Botão Agendar
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _agendarConsulta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan[500],
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Agendar Consulta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20), // Espaço extra no final
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildResumo() {
    final psicologo = _psicologoSelecionado != null
        ? _psicologos.firstWhere((p) => p.id == _psicologoSelecionado)
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              SizedBox(width: 8),
              Text(
                'Resumo da Consulta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (psicologo != null) ...[
            _buildResumoItem('Psicólogo:', psicologo.name),
            const SizedBox(height: 8),
          ],
          if (_dataSelecionada != null) ...[
            _buildResumoItem('Data:',
                '${_dataSelecionada!.day.toString().padLeft(2, '0')}/${_dataSelecionada!.month.toString().padLeft(2, '0')}/${_dataSelecionada!.year}'),
            const SizedBox(height: 8),
          ],
          if (_horarioSelecionado != null) ...[
            _buildResumoItem('Horário:', _horarioSelecionado!),
            const SizedBox(height: 8),
          ],
          if (_modalidadeSelecionada != null) ...[
            _buildResumoItem('Modalidade:', _modalidadeSelecionada!),
            const SizedBox(height: 8),
          ],
          if (_isFirstConsultation) ...[
            _buildResumoItem('Observação:', 'Primeira consulta'),
          ],
        ],
      ),
    );
  }

  Widget _buildResumoItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.blue[700],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selecionarData() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 90)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.cyan[600]!,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.cyan[600],
                ),
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && picked != _dataSelecionada) {
        setState(() {
          _dataSelecionada = picked;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _agendarConsulta() async {
    if (!(_formKey.currentState!.validate() && _dataSelecionada != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final psicologo =
          _psicologos.firstWhere((p) => p.id == _psicologoSelecionado);
      await ApiService.scheduleAppointment(
        psicologo: psicologo,
        data: _dataSelecionada!,
        horario: _horarioSelecionado!,
        modalidade: _modalidadeSelecionada!,
        motivo: _motivoController.text,
      );
      if (!mounted) return;
      // Navega imediatamente para a lista de consultas após agendar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Consulta agendada com sucesso!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/consultas-agendadas',
        (route) => route.settings.name == '/inicio',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao agendar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }
}