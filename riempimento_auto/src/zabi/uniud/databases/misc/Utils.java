package zabi.uniud.databases.misc;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

import zabi.uniud.databases.Progetto;

public class Utils {

	public static final String MESI = "ABCDEHLMPRST";
	public static final String[] nazioni = {"USA", "ITA", "ENG", "JPN", "FRA", "GER", "POR", "SPA", "NOR", "SWE", "DEN", "FIN", "CHN", "IND", "AUS", "MEX", "BRA", "SWI", "GRE", "RUS", "NKO", "SKO", "POL", "EST", "LIT", "HUN"};
	public static final String[] mansioni = {"biglietti", "bar", "sale", "tech video", "tech audio", "bagni", "sicurezza", "emergenze", "check biglietti"};
	public static final String[] ruoli = {"Protagonista", "Comparsa", "Antagonista", "Narratore", "Personaggio", "Altro"};
	public static List<String> citta;
	public static List<String> nomi;
	
	static {
		try (BufferedReader in = new BufferedReader(new FileReader(new File("citta.txt")))) {
			citta = in.lines().collect(Collectors.toList());
		} catch (IOException e) {
			e.printStackTrace();
		}

		try (BufferedReader in = new BufferedReader(new FileReader(new File("nomi_italiani.txt")))) {
			nomi = in.lines().collect(Collectors.toList());
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static String mansione() {
		return mansioni[Progetto.rng.nextInt(mansioni.length)];
	}
	
	public static String ruolo() {
		return ruoli[Progetto.rng.nextInt(ruoli.length)];
	}

	public static String cfFromName(String nome) {
		StringBuilder sb = new StringBuilder();
		int chars = 0;
		String upper = nome.toUpperCase();
		for (int i = 0; i < nome.length() && chars < 6; i++) {
			char current = upper.charAt(i);
			if (current <= 'Z' && current >= 'A' && !Utils.isVocal(current)) {
				sb.append(current);
				chars++;
			}
		}
		for (int i = 0; i < nome.length() && chars < 6; i++) {
			char current = upper.charAt(i);
			if (current <= 'Z' && current >= 'A' && Utils.isVocal(current)) {
				sb.append(current);
				chars++;
			}
		}
		sb.append(30 + Progetto.rng.nextInt(70));
		sb.append(Utils.MESI.charAt(Progetto.rng.nextInt(Utils.MESI.length())));
		int giorno = 1 + Progetto.rng.nextInt(28);
		if (Progetto.rng.nextBoolean()) {
			giorno += 40;
		}
		sb.append(giorno);
		char sigla = (char) ('A' + Progetto.rng.nextInt(26));
		sb.append(sigla);
		int cod = 100+Progetto.rng.nextInt(900);
		sb.append(cod);
		char control = (char) ('A' + Progetto.rng.nextInt(26));
		sb.append(control);
		return sb.toString();
	}

	public static boolean isVocal(char in) {
		return in == 'A' || in == 'E' || in == 'I' || in == 'O' || in == 'U';
	}

	public static String telefonoRandom() {
		StringBuilder tel = new StringBuilder("+39 0");
		for (int i = 0; i < 9; i++) {
			tel.append(Progetto.rng.nextInt(10));
		}
		return tel.toString();
	}

	public static String cittaRandom() {
		return Utils.citta.get(Progetto.rng.nextInt(Utils.citta.size()));
	}

}
