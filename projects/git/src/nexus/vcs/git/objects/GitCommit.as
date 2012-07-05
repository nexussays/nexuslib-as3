// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git.objects
{

import flash.utils.ByteArray;
import flash.utils.IDataInput;
import nexus.vcs.git.*;

/**
 * An object epresenting a commit
 * @see: http://www.kernel.org/pub/software/scm/git/docs/v1.7.3/user-manual.html#commit-object
 */
public class GitCommit extends AbstractGitObject
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_tree:GitTree;
	private var m_parents:Vector.<GitCommit>;
	private var m_author:String;
	private var m_committer:String;
	private var m_comment:String;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitCommit(hash:String, repo:GitRepository)
	{
		super(hash, repo);
		
		m_parents = new Vector.<GitCommit>();
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	override public function get type():String { return ObjectType.COMMIT; }
	
	/**
	 * The tree object this commit points to.
	 */
	public function get tree():GitTree { return m_tree; }
	
	/**
	 * Some number of commits which represent the immediately previous step(s) in the
	 * history of the project. Most commits have one parent; merge commits may have more than one.
	 */
	public function get parents():Vector.<GitCommit> { return m_parents; }
	
	/**
	 * A commit with no parents is called a "root" commit, and represents the initial revision of a project.
	 * Each project must have at least one root. A project can also have multiple roots, though that isn't
	 * common (or necessarily a good idea).
	 */
	public function get isRootCommit():Boolean
	{
		return m_parents.length == 0;
	}
	
	/**
	 * The name of the person responsible for this change, together with its date.
	 */
	public function get author():String { return m_author; }
	
	/**
	 * The name of the person who actually created the commit, with the date it was done.
	 * This may be different from the author, for example, if the author was someone who wrote a patch and
	 * emailed it to the person who used it to create the commit.
	 */
	public function get committer():String { return m_committer; }
	
	/**
	 * A comment describing this commit.
	 */
	public function get comment():String { return m_comment; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	override public function generateBytes():ByteArray
	{
		return super.generateBytes();
	}
	
	override public function populateContent(content:IDataInput, size:int):void
	{
		super.populateContent(content, size);
		
		m_tree = null;
		m_parents.splice(0, m_parents.length);
		m_author = null;
		m_committer = null;
		m_comment = null;
		
		var commitLines:Array = content.readUTFBytes(content.bytesAvailable).split("\n");
		while(commitLines.length > 0)
		{
			var line : String = commitLines.shift();
			//the committer is the last line before the commit comment, so if it's still null then we're still iterating over the commit metadata
			if(m_committer == null)
			{
				var lineParts:Array = line.match(/([^ ]+) (.+)/);
				switch(lineParts[1])
				{
					case "tree":
						m_tree = new GitTree(lineParts[2], m_repo);
						break;
					case "parent":
						m_parents.push(new GitCommit(lineParts[2], m_repo));
						break;
					case "author":
						//TODO: Parse this into some typed object w/ email, date, etc
						m_author = lineParts[2];
						break;
					//committer is the last metadata field, it is followed by an empty line and then the commit message
					case "committer":
						m_committer = lineParts[2];
						//remove the empty line
						commitLines.shift();
						//join the comment back together
						m_comment = commitLines.join("\n");
						//clear the array
						commitLines.length = 0;
						break;
					default:
						throw new Error("Unexpected format in commit " + m_hash + ".\n" + content);
						break;
				}
			}
		}
	}
	
	/**
	 * Return a string reprsentation of this object
	 * @param	verbose	If true, the object header is output as well
	 * @return	This object as a string
	 */
	override public function toString(verbose:Boolean=false):String
	{
		var header : String = "";
		if(verbose)
		{
			header = "commit " + size + "\n";
		}
		header += "tree " + m_tree.hash + "\n";
		//oh, if only
		//header += "parent ${x.hash}\n" foreach x in m_parents
		for each(var commit : GitCommit in m_parents)
		{
			header += "parent " + commit.hash + "\n";
		}
		return header +
			"author " + m_author + "\n" +
			"committer " + m_committer + "\n" +
			"\n" +
			m_comment;
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}