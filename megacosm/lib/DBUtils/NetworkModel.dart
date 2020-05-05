import 'package:floor/floor.dart';
@entity
class Network {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String name;
  final String url;
  final String denom;
  final bool active;

  Network(this.id, this.name, this.url, this.denom, this.active);
}

@dao
abstract class NetworkDao {
  @Query('SELECT * FROM Network')
  Future<List<Network>> allNetworks();

  @Query('SELECT * FROM Network WHERE id = :id')
  Stream<Network> findNetworkById(int id);
  @Query('SELECT * FROM Network WHERE active = true')
  Future<List<Network>> findActiveNetwork();
  @update
  Future<int> updateNetwork(List<Network> networks);
  @insert
  Future<void> insertNetwork(Network network);
  @insert
  Future<void> insertNetworkList(List<Network> network);
  @delete
  Future<int> deleteNetworks(List<Network> network);
}