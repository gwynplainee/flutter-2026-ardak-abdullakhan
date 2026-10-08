import 'package:flutter/material.dart';

import 'contact_card.dart';
import 'contacts.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            '${contacts.length} contacts',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary, // polish
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) =>
                ContactCard(contact: contacts[index]),
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      ],
    );
  }
}
