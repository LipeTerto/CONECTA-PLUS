import 'package:material_ui/material_ui.dart';

import '../models/event_model.dart';
import '../models/initiative_model.dart';
import '../models/institution_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'item_card.dart';

/// Card de um evento (usado nas listas, nos favoritos e na Home).
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.onTap});

  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      title: event.title,
      subtitle: '${Formatters.date(event.eventDate)} • '
          '${Formatters.time(event.eventTime)} • '
          '${event.locationName}',
      category: event.category,
      icon: Icons.event,
      color: AppTheme.eventsColor,
      onTap: onTap,
    );
  }
}

/// Card de uma instituição.
class InstitutionCard extends StatelessWidget {
  const InstitutionCard({
    super.key,
    required this.institution,
    required this.onTap,
  });

  final InstitutionModel institution;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      title: institution.name,
      subtitle: institution.address,
      category: institution.category,
      icon: Icons.volunteer_activism,
      color: AppTheme.institutionsColor,
      onTap: onTap,
    );
  }
}

/// Card de uma iniciativa.
class InitiativeCard extends StatelessWidget {
  const InitiativeCard({
    super.key,
    required this.initiative,
    required this.onTap,
  });

  final InitiativeModel initiative;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      title: initiative.title,
      subtitle: '${initiative.organizationName} • ${initiative.location}',
      category: initiative.category,
      icon: Icons.lightbulb,
      color: AppTheme.initiativesColor,
      onTap: onTap,
    );
  }
}