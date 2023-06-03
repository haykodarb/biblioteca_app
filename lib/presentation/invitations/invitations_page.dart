import 'package:communal/models/invitation.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_scaffold/common_scaffold_widget.dart';
import 'package:communal/presentation/invitations/invitations_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvitationsPage extends StatelessWidget {
  const InvitationsPage({super.key});

  Widget _invitationElement(InvitationsController controller, Invitation invitation) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          height: 275,
          child: Obx(
            () {
              return CommonLoadingBody(
                isLoading: invitation.loading.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      invitation.communityName,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Expanded(child: VerticalDivider()),
                        SizedBox(
                          width: 80,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => controller.respondToInvitation(invitation, true),
                            child: const Icon(Icons.done),
                          ),
                        ),
                        const VerticalDivider(width: 30),
                        SizedBox(
                          width: 80,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () => controller.respondToInvitation(invitation, false),
                            child: const Icon(Icons.close),
                          ),
                        ),
                        const Expanded(child: VerticalDivider()),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: InvitationsController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Invitations'),
          ),
          drawer: const CommonScaffoldWidget(),
          body: Obx(
            () {
              return CommonLoadingBody(
                isLoading: controller.loading.value,
                child: RefreshIndicator(
                  onRefresh: controller.loadInvitations,
                  child: Obx(
                    () {
                      if (controller.invitationsList.isEmpty) {
                        return const CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  'You have not received\nany invitations yet.',
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.separated(
                        itemCount: controller.invitationsList.length,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        itemBuilder: (context, index) {
                          return _invitationElement(controller, controller.invitationsList[index]);
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
