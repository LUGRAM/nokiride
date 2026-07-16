import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  static const questions = <(String, String)>[
    (
      'Comment suivre mon chauffeur ou mon coursier ?',
      'Après l’affectation, la carte affiche sa position GPS réelle. En cas de coupure, la dernière position connue reste visible et le suivi reprend automatiquement.'
    ),
    (
      'Pourquoi l’itinéraire peut-il changer ?',
      'NokiRide recalcule le trajet lorsque le conducteur s’éloigne sensiblement de la route prévue. Le trafic peut aussi modifier l’ETA.'
    ),
    (
      'Que faire si le conducteur ne bouge plus ?',
      'Vérifiez votre connexion puis patientez quelques instants. Si la position reste figée, contactez le support avec la référence concernée.'
    ),
    (
      'Comment signaler un problème de paiement ?',
      'Choisissez Paiement dans le formulaire support et indiquez la référence affichée dans votre portefeuille ou votre reçu.'
    ),
    (
      'Comment protéger mon compte ?',
      'Ne communiquez jamais votre code OTP. NokiRide ne vous demandera pas votre mot de passe ou votre code de validation par téléphone.'
    ),
  ];

  @override
  Widget build(BuildContext context) => _SupportScaffold(
        title: 'Centre d’aide & FAQ',
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == questions.length) {
              return FilledButton.icon(
                onPressed: () => Get.toNamed('/support/contact'),
                icon: const Icon(Icons.support_agent_rounded),
                label: const Text('Contacter le support'),
              );
            }
            final item = questions[index];
            return Card(
              margin: EdgeInsets.zero,
              color: AppColors.surface(context),
              child: ExpansionTile(
                title: Text(item.$1,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(item.$2),
                  )
                ],
              ),
            );
          },
        ),
      );
}

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});
  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  String category = 'trip';
  bool submitting = false;

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate() || submitting) return;
    setState(() => submitting = true);
    try {
      final response =
          await ApiClient.instance.post('/support/requests', data: {
        'category': category,
        'subject': subjectController.text.trim(),
        'message': messageController.text.trim(),
      });
      final data = response['data'];
      final reference = data is Map ? data['reference'] : null;
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
          title: const Text('Demande envoyée'),
          content: Text(reference == null
              ? 'Le support a bien reçu votre demande.'
              : 'Référence : $reference\nConservez-la pour le suivi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            )
          ],
        ),
      );
      subjectController.clear();
      messageController.clear();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => _SupportScaffold(
        title: 'Contacter le support',
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Ne communiquez jamais de mot de passe ou de code OTP.',
                  style: TextStyle(color: AppColors.textSub(context))),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(
                    labelText: 'Catégorie', border: OutlineInputBorder()),
                items: const {
                  'trip': 'Course',
                  'delivery': 'Livraison',
                  'payment': 'Paiement',
                  'account': 'Compte',
                  'safety': 'Sécurité',
                  'other': 'Autre',
                }
                    .entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => category = value!),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: subjectController,
                decoration: const InputDecoration(
                    labelText: 'Sujet', border: OutlineInputBorder()),
                validator: (value) => (value?.trim().length ?? 0) < 4
                    ? 'Indiquez un sujet plus précis.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: messageController,
                minLines: 6,
                maxLines: 10,
                maxLength: 4000,
                decoration: const InputDecoration(
                    labelText: 'Votre message',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder()),
                validator: (value) => (value?.trim().length ?? 0) < 10
                    ? 'Décrivez le problème en quelques phrases.'
                    : null,
              ),
              FilledButton.icon(
                onPressed: submitting ? null : submit,
                icon: submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: const Text('Envoyer la demande'),
              ),
            ],
          ),
        ),
      );
}

class LegalCenterPage extends StatelessWidget {
  const LegalCenterPage({super.key});
  @override
  Widget build(BuildContext context) => const _SupportScaffold(
        title: 'Support & légal',
        child: _LegalContent(),
      );
}

class _LegalContent extends StatelessWidget {
  const _LegalContent();
  static const sections = <(String, String)>[
    (
      'Conditions d’utilisation',
      'NokiRide met en relation des clients et des conducteurs ou coursiers. Chaque utilisateur doit fournir des informations exactes, respecter les personnes et utiliser le service uniquement à des fins légales.'
    ),
    (
      'Confidentialité et localisation',
      'La localisation est utilisée pour l’affectation, le suivi d’une prestation active, la sécurité et l’amélioration du service. Le partage temps réel est limité aux participants autorisés.'
    ),
    (
      'Paiements et annulations',
      'Le montant, le moyen de paiement et l’état de la transaction sont affichés avant confirmation. Toute contestation doit être envoyée au support avec la référence concernée.'
    ),
    (
      'Sécurité',
      'En cas de danger immédiat, contactez d’abord les services d’urgence locaux. Ne partagez jamais un code OTP, un mot de passe ou des données financières.'
    ),
    (
      'Vos choix',
      'Vous pouvez modifier votre profil et demander assistance pour l’accès, la correction ou la suppression de données, sous réserve des obligations légales de conservation.'
    ),
  ];
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...sections.map((section) => Card(
                color: AppColors.surface(context),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section.$1,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(section.$2, style: const TextStyle(height: 1.45)),
                    ],
                  ),
                ),
              )),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Dernière mise à jour : 16 juillet 2026',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ],
      );
}

class _SupportScaffold extends StatelessWidget {
  const _SupportScaffold({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
            title: Text(title),
            backgroundColor: AppColors.background(context),
            surfaceTintColor: Colors.transparent),
        body: SafeArea(child: child),
      );
}
