package zabi.uniud.databases;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Properties;
import java.util.Random;

import zabi.uniud.databases.misc.Counter;
import zabi.uniud.databases.misc.Utils;

public class Progetto {

	public static final Random rng = new Random();
	public static String url = "jdbc:postgresql://192.168.1.57:5432/laboratorio"; //Lanciare con argomento JVM -Dserver="ilMioServer.com:porta/ilMioDB"
	public static final Properties props = new Properties();


	public static void main(String[] args) throws ClassNotFoundException {
		props.setProperty("user", args[0]);
		props.setProperty("password", args[1]);
		props.setProperty("ssl","false");
		if (System.getProperty("server") != null) {
			url = "jdbc:postgresql://"+System.getProperty("server");
		}
		Class.forName("org.postgresql.Driver");
		populate();	
		System.out.println("DONE");
	}


	public static void populate() {
		try (Connection conn = DriverManager.getConnection(url, props)) {
			int film = inserisciFilm(300, conn);
			inserisciAttori(200, film, conn);
			int cinema = inserisciCinema(100, conn);
			inserisciDipendentiEMansioni(500, cinema, 3, conn);
			inserisciSaleEProiezioni(16, cinema, film, conn);
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	@SuppressWarnings("deprecation")
	public static void inserisciSaleEProiezioni(int max, int cinema_tot, int film_tot, Connection conn) {
		System.out.println("Sale");
		try {
			PreparedStatement statement_sala = conn.prepareStatement("INSERT INTO sale VALUES(?, ?, ?, ?);");
			PreparedStatement statement_proj = conn.prepareStatement("INSERT INTO proiezioni(costo, vendite, datetime, idfilm, idsala, idcinema, capienza_sala, fine_proiezione) VALUES(?, ?, ?, ?, ?, ?, ?, ?);");
			for (int cinema = 1; cinema <= cinema_tot; cinema++) {
				int saleDelCinema = 1 + rng.nextInt(max);
				for (int sala = 0; sala < saleDelCinema; sala++) {
					try {
						int posti = 100 + rng.nextInt(400);
						statement_sala.setInt(1, sala);
						statement_sala.setInt(2, cinema);
						statement_sala.setInt(3, 400 + rng.nextInt(600));
						statement_sala.setInt(4, posti);
						statement_sala.executeUpdate();

						int proiezioniTotSala = rng.nextInt(50) + 10;

						for (int proj = 0; proj < proiezioniTotSala; proj++) {
							statement_proj.setDouble(1, 4 + rng.nextInt(10) + rng.nextInt(100)/100d);
							statement_proj.setInt(2, 1 + rng.nextInt(posti));
							statement_proj.setDate(3, new Date(110+rng.nextInt(10), rng.nextInt(12), rng.nextInt(28)));
							statement_proj.setInt(4, 1 + rng.nextInt(film_tot - 1));
							statement_proj.setInt(5, sala);
							statement_proj.setInt(6, cinema);
							statement_proj.setInt(7, 0);
							statement_proj.setDate(8, new Date(0));
							statement_proj.executeUpdate();
						}

					} catch (SQLException sqle) {
						throw new RuntimeException(sqle);
					}
				};
			}
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
	}



	@SuppressWarnings("deprecation")
	public static void inserisciDipendentiEMansioni(int quanti, int cinemaTot, int mansioniMaxPerPersona, Connection conn) {
		System.out.println("Dipendenti e mansioni");
		try {
			PreparedStatement statementDipendente = conn.prepareStatement("INSERT INTO dipendenti VALUES(?, ?, ?);");
			PreparedStatement statementMansione = conn.prepareStatement("INSERT INTO impieghi_correnti VALUES(?, ?, ?, ?, ?);");
			for (int i = 0; i < quanti; i++) {
				try {
					String nome = Utils.nomi.get(rng.nextInt(Utils.nomi.size())) + " " + Utils.nomi.get(rng.nextInt(Utils.nomi.size()));
					String cf = Utils.cfFromName(nome);
					statementDipendente.setString(1, cf);
					statementDipendente.setString(2, nome);
					statementDipendente.setString(3, Utils.telefonoRandom());
					statementDipendente.executeUpdate();
					int mansioni = 1 + rng.nextInt(mansioniMaxPerPersona);
					
					for (int j = 0; j < mansioni; j++) {
						int cinema_curr = 1 + rng.nextInt(cinemaTot);
						String mansione = j==0?"manager":Utils.mansione();
						statementMansione.setString(1, cf);
						statementMansione.setInt(2, cinema_curr);
						statementMansione.setString(3, mansione);
						statementMansione.setDate(4, new Date(110 + rng.nextInt(10), 1 + rng.nextInt(11), 1 + rng.nextInt(28)));
						statementMansione.setInt(5, 800 + rng.nextInt(1000));
						try { statementMansione.executeUpdate(); } catch (Exception ahkdba) {if (j==0) ahkdba.printStackTrace();}
					}
				} catch (SQLException sqle) {
					throw new RuntimeException(sqle);
				}
			};
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
	}

	public static int inserisciCinema(int max, Connection conn) {
		System.out.println("Cinema");
		final Counter count = new Counter();
		try (BufferedReader in = new BufferedReader(new FileReader(new File("cinema.txt")))) {
			PreparedStatement statement = conn.prepareStatement("INSERT INTO cinema(citta, nome, telefono, totale_dipendenti) VALUES(?, ?, ?, ?);");

			in.lines().limit(max).forEach(nome -> {
				try {
					statement.setString(1, Utils.cittaRandom());
					statement.setString(2, nome);
					statement.setString(3, Utils.telefonoRandom());
					statement.setInt(4, 0);
					statement.executeUpdate();
				} catch (SQLException sqle) {
					throw new RuntimeException(sqle);
				}
				count.times++;
			});
		} catch (IOException e) {
			throw new RuntimeException(e);
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
		return count.times;
	}


	public static int inserisciFilm(int max, Connection conn) {
		System.out.println("Film");
		Counter count = new Counter();
		try (BufferedReader in = new BufferedReader(new FileReader(new File("titoli_orignali.txt")))) {

			PreparedStatement statement = conn.prepareStatement("INSERT INTO film(durata, regia, anno, rating, titolo, nazione, sequel_di, proiezioni_totali) VALUES(?, ?, ?, ?, ?, ?, ?, ?);");

			in.lines().limit(max).forEach(titolo -> {
				try {
					statement.setInt(1, 30+rng.nextInt(200));
					statement.setString(2, "regista_generico_"+count.times);
					statement.setInt(3, 1930 + rng.nextInt(91));
					statement.setInt(4, rng.nextInt(5) + 1);
					statement.setString(5, titolo);
					statement.setString(6, Utils.nazioni[rng.nextInt(Utils.nazioni.length)]);
					if (rng.nextInt(40)==0 && count.times > 5) {
						statement.setInt(7, count.times - 3);
					} else {
						statement.setNull(7, java.sql.Types.INTEGER);
					}
					statement.setInt(8, 0);
					statement.executeUpdate();
				} catch (SQLException sqle) {
					throw new RuntimeException(sqle);
				}
				count.times++;
			});
		} catch (IOException e) {
			throw new RuntimeException(e);
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
		return count.times;
	}

	public static void inserisciAttori(int max, int film, Connection conn) {
		System.out.println("Attori e ruoli");
		try (BufferedReader in = new BufferedReader(new FileReader(new File("actor_list.txt")))) {
			PreparedStatement attore = conn.prepareStatement("INSERT INTO attori VALUES(?, ?);");
			PreparedStatement ruolo = conn.prepareStatement("INSERT INTO ruoli VALUES(?, ?, ?);");
			in.lines().limit(max).forEach(nome -> {
				try {
					String cf = Utils.cfFromName(nome);
					attore.setString(2, nome);
					attore.setString(1, cf);
					attore.executeUpdate();

					int ruoli = rng.nextInt(5);

					HashSet<Integer> ids = new HashSet<>();
					while (ids.size() < ruoli) {
						ids.add(1 + rng.nextInt(film));
					}

					for (int j : ids) {
						ruolo.setString(1, cf);
						ruolo.setInt(2, j);
						ruolo.setString(3, Utils.ruolo());
						try {
							ruolo.executeUpdate();
						} catch (SQLException e1) {
							throw new RuntimeException(e1);
						}
					}

				} catch (SQLException e) {
					throw new RuntimeException(e);
				}
			});
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

}
