import 'package:fluent_ui/fluent_ui.dart';
import 'package:stibu/appwrite.models.dart';
import 'package:stibu/common/models_extensions.dart';

class CustomerInfoCard extends StatelessWidget {
  final Customers customer;

  const CustomerInfoCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 150,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: FluentTheme.of(context).typography.subtitle,
                  ),
                  Text('ID: ${customer.id}'),
                  const Spacer(),
                  Text(customer.street ?? ''),
                  Text(customer.zipWithCityFormatted),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (customer.email != null)
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(FluentIcons.mail),
                        ),
                        Text(customer.email!),
                      ],
                    ),
                  if (customer.phone != null)
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(FluentIcons.phone),
                        ),
                        Text(customer.phone!,
                            style: FluentTheme.of(context).typography.caption),
                      ],
                    ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
