// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Proposal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Proposal _$ProposalFromJson(Map<String, dynamic> json) {
  return Proposal(
    proposal_id: json['proposal_id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    proposal_status: json['proposal_status'] as String,
    final_tally_result: ProposalResult.fromJson(
        json['final_tally_result'] as Map<String, dynamic>),
    proposal_type: json['proposal_type'] as String,
    submit_time: json['submit_time'] as String,
    total_deposit: (json['total_deposit'] as List)
        .map((e) => ProposalDeposits.fromJson(e as Map<String, dynamic>))
        .toList(),
    voting_start_time: json['voting_start_time'] as String,
  );
}

Map<String, dynamic> _$ProposalToJson(Proposal instance) => <String, dynamic>{
      'proposal_id': instance.proposal_id,
      'title': instance.title,
      'description': instance.description,
      'proposal_type': instance.proposal_type,
      'proposal_status': instance.proposal_status,
      'final_tally_result': instance.final_tally_result,
      'submit_time': instance.submit_time,
      'total_deposit': instance.total_deposit,
      'voting_start_time': instance.voting_start_time,
    };
