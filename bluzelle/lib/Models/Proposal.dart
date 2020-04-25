import 'package:bluzelle/Models/ProposalDeposits.dart';
import 'package:bluzelle/Models/ProposalResult.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Proposal.g.dart';

@JsonSerializable(nullable: false)
class Proposal{
  final int proposal_id;
  final String title;
  final String description;
  final String proposal_type;
  final String proposal_status;
  final ProposalResult final_tally_result;
  final String submit_time;
  final List<ProposalDeposits> total_deposit;
  final String voting_start_time;
  Proposal({this.proposal_id, this.title, this.description, this.proposal_status,this.final_tally_result,this.proposal_type,this.submit_time,this.total_deposit,this.voting_start_time,});
  factory Proposal.fromJson(Map<String, dynamic> json) => _$ProposalFromJson(json);
  Map<String, dynamic> toJson() => _$ProposalToJson(this);
}